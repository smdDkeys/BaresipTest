//
//  ViewController.swift
//  BarSipTest
//
//  Created by Vera Kuznetsova on 05.04.2021.
//

import UIKit
import AVFoundation
import CFNetwork
import CoreMedia
import AudioToolbox
import CoreVideo
import iOSH264Compression
import OpenGLES

class ViewController: UIViewController {

    @IBOutlet weak var viewMy: UIView!
    @IBOutlet weak var decodeView: UIView!
    @IBOutlet weak var StateCallLabel: UILabel!
    let vTCompressionH264:VTCompressionH264Encode = VTCompressionH264Encode()
    let vTCompressionH264Decode:VTCompressionH264Decode = VTCompressionH264Decode()
    var agent: OpaquePointer? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        StateCallLabel.text = ""
        vTCompressionH264Decode.delegate = self
        test()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.startEncode()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.stopEncode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func myBuutTest(_ sender: Any) {
        // Make an outgoing call.
        
        guard ua_connect(agent, nil, nil, "sip:999998@192.168.0.148", VIDMODE_ON/*VIDMODE_OFF*/) == 0 else { return }

        // Start the main loop.
        DispatchQueue.global(qos: .userInitiated).async {
                re_main(nil)
        }
    }
    
    func close(agent: OpaquePointer) {
            mem_deref(UnsafeMutablePointer(agent))
            ua_close()
            mod_close()

            // Close and check for memory leaks.
            libre_close()
            tmr_debug()
            mem_debug()
    }
    
    var IncCall: OpaquePointer? = nil
    
    func cFunction(_ block: (@escaping @convention(block) () -> ()))
        -> (@convention(c) () -> ()) {
        return unsafeBitCast(
            imp_implementationWithBlock(block),
            to: (@convention(c) () -> ()).self
        )
    }
    
    func contentsOfDirectoryAtPath(path: String) -> [String]? {
        guard let paths = try? FileManager.default.contentsOfDirectory(atPath: path) else { return nil}
        return paths.map { aContent in (path as NSString).appendingPathComponent(aContent)}
    }
    
    func readFileConfig(path: String?) {
        if let filepath = path {
            print("-------------")
            do {
                let contents = try String(contentsOfFile: filepath)
                print(contents)
                print("--------------")
            }
            catch {
                // contents could not be loaded
            }
            
        } else {
            // example.txt not found!
        }
    }
    
    func test() {
        //var agent: OpaquePointer? = nil
        print(Date())
        guard libre_init() == 0 else { return }
        
        
        // Initialize dynamic modules.
        mod_init()
        
        let configText = """
        #
        # baresip configuration
        #

        #------------------------------------------------------------------------------

        # Core
        poll_method        kqueue        # poll, select, kqueue ..

        # SIP
        #sip_listen        0.0.0.0:5060
        #sip_certificate    cert.pem
        sip_cafile        /etc/ssl/cert.pem
        #sip_trans_def        udp
        sip_verify_server    yes

        # Call
        call_local_timeout    120
        call_max_calls        4
        call_hold_other_calls    yes

        # Audio
        #audio_path        /share/baresip
        audio_player        audiounit,default
        audio_source        audiounit,default
        audio_alert        audiounit,default
        #ausrc_srate        48000
        #auplay_srate        48000
        #ausrc_channels        0
        #auplay_channels    0
        #audio_txmode        poll        # poll, thread
        audio_level        no
        ausrc_format        s16        # s16, float, ..
        auplay_format        s16        # s16, float, ..
        auenc_format        s16        # s16, float, ..
        audec_format        s16        # s16, float, ..
        audio_buffer        20-160        # ms

        # Video
        video_source        avcapture,nil
        video_display        sdl,nil
        video_size        640x480
        video_bitrate        1000000
        video_fps        30.00
        video_fullscreen    no
        videnc_format        yuv420p

        # AVT - Audio/Video Transport
        rtp_tos            184
        #rtp_ports        10000-20000
        #rtp_bandwidth        512-1024 # [kbit/s]
        rtcp_mux        no
        jitter_buffer_type    fixed        # off, fixed, adaptive
        jitter_buffer_delay    5-10        # frames
        #jitter_buffer_wish    6        # frames for start
        rtp_stats        no
        #rtp_timeout        60

        # Network
        #dns_server        1.1.1.1:53
        #dns_server        1.0.0.1:53
        #dns_fallback        8.8.8.8:53
        #net_interface        eth0
        # Play tones
        #file_ausrc        aufile
        #file_srate        16000
        #file_channels        1

        #------------------------------------------------------------------------------
        # Modules

        #module_path        /lib/baresip/modules

        # UI Modules
        module            stdio.so
        #module            cons.so
        #module            evdev.so
        #module            httpd.so

        # Audio codec Modules (in order)
        #module            opus.so
        #module            amr.so
        #module            g7221.so
        #module            g722.so
        #module            g726.so
        module            g711.so
        #module            gsm.so
        #module            l16.so
        #module            mpa.so
        #module            codec2.so
        #module            ilbc.so

        # Audio filter Modules (in encoding order)
        #module            vumeter.so
        #module            sndfile.so
        #module            speex_pp.so
        #module            plc.so
        #module            webrtc_aec.so

        # Audio driver Modules
        #module            coreaudio.so
        module            audiounit.so
        #module            jack.so
        #module            portaudio.so
        #module            aubridge.so
        #module            aufile.so
        #module            ausine.so

        # Video codec Modules (in order)
        module            avcodec.so
        #module            vp8.so
        #module            vp9.so

        # Video filter Modules (in encoding order)
        #module            selfview.so
        #module            snapshot.so
        #module            swscale.so
        #module            vidinfo.so
        #module            avfilter.so

        # Video source modules
        module            avcapture.so
        #module            x11grab.so
        #module            cairo.so
        #module            vidbridge.so

        # Video display modules
        #module            x11.so
        module            sdl.so
        #module            opengles.so
        #module            fakevideo.so

        # Audio/Video source modules
        module            avformat.so
        #module            rst.so
        #module            gst.so
        #module            gst_video.so

        # Compatibility modules
        #module            ebuacip.so

        # Media NAT modules
        #module            stun.so
        #module            turn.so
        #module            ice.so
        #module            natpmp.so
        #module            pcp.so

        # Media encryption modules
        #module            srtp.so
        #module            dtls_srtp.so
        #module            zrtp.so


        #------------------------------------------------------------------------------
        # Temporary Modules (loaded then unloaded)

        #module_tmp        uuid.so
        module_tmp        account.so


        #------------------------------------------------------------------------------
        # Application Modules

        module_app        auloop.so
        #module_app        b2bua.so
        module_app        contact.so
        module_app        debug_cmd.so
        #module_app        echo.so
        #module_app        gtk.so
        module_app        menu.so
        #module_app        mwi.so
        #module_app        presence.so
        #module_app        serreg.so
        #module_app        syslog.so
        #module_app        mqtt.so
        #module_app        ctrl_tcp.so
        module_app        vidloop.so
        #module_app        ctrl_dbus.so
        #module_app        httpreq.so
        #module_app        multicast.so


        #------------------------------------------------------------------------------
        # Module parameters


        # UI Modules parameters
        cons_listen        0.0.0.0:5555 # cons - Console UI UDP/TCP sockets

        http_listen        0.0.0.0:8000 # httpd - HTTP Server

        ctrl_tcp_listen        0.0.0.0:4444 # ctrl_tcp - TCP interface JSON

        evdev_device        /dev/input/event0

        # Opus codec parameters
        opus_bitrate        28000 # 6000-510000
        #opus_stereo        yes
        #opus_sprop_stereo    yes
        #opus_cbr        no
        #opus_inbandfec        no
        #opus_dtx        no
        #opus_mirror        no
        #opus_complexity    10
        #opus_application    audio    # {voip,audio}
        #opus_samplerate    48000
        #opus_packet_loss    10    # 0-100 percent (expected packet loss)

        # Opus Multistream codec parameters
        #opus_ms_channels    2    #total channels (2 or 4)
        #opus_ms_streams    2    #number of streams
        #opus_ms_c_streams    2    #number of coupled streams

        vumeter_stderr        yes

        #jack_connect_ports    yes

        # Selfview
        video_selfview        window # {window,pip}
        #selfview_size        64x64

        # ZRTP
        #zrtp_hash        no  # Disable SDP zrtp-hash (not recommended)

        # Menu
        #redial_attempts    0 # Num or <inf>
        #redial_delay        5 # Delay in seconds
        #ringback_disabled    no
        #statmode_default    off
        #menu_clean_number    no
        #sip_autoanswer_beep    yes
        #sip_autoanswer_method    rfc5373 # {rfc5373,call-info,alert-info}
        #ring_aufile        ring.wav
        #callwaiting_aufile    callwaiting.wav
        #ringback_aufile    ringback.wav
        #notfound_aufile    notfound.wav
        #busy_aufile        busy.wav
        #error_aufile        error.wav
        #sip_autoanswer_aufile    autoanswer.wav

        # GTK
        #gtk_clean_number    no

        # avcodec
        #avcodec_h264enc    libx264
        #avcodec_h264dec    h264
        #avcodec_h265enc    libx265
        #avcodec_h265dec    hevc
        #avcodec_hwaccel    videotoolbox

        # ctrl_dbus
        #ctrl_dbus_use    system        # system, session

        # mqtt
        #mqtt_broker_host    sollentuna.example.com
        #mqtt_broker_port    1883
        #mqtt_broker_cafile    /path/to/broker-ca.crt    # set this to enforce TLS
        #mqtt_broker_clientid    baresip01    # has to be unique
        #mqtt_broker_user    user
        #mqtt_broker_password    pass
        #mqtt_basetopic        baresip/01

        # sndfile
        #snd_path        /tmp

        # EBU ACIP
        #ebuacip_jb_type    fixed    # auto,fixed

        # HTTP request module
        #httpreq_ca        trusted1.pem
        #httpreq_ca        trusted2.pem
        #httpreq_dns        1.1.1.1
        #httpreq_dns        8.8.8.8
        #httpreq_hostname    myserver
        #httpreq_cert        cert.pem
        #httpreq_key        key.pem

        # multicast receivers (in priority order)- port number must be even
        #multicast_call_prio    0
        #multicast_listener    224.0.2.21:50000
        #multicast_listener    224.0.2.21:50002
        """

        var myPath = ""
        
        // Make configure file.
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let allFiles = contentsOfDirectoryAtPath(path: path)
            print("Все файлы в каталоге - \(String(describing: allFiles))")
            print("Второй файл в каталоге:")
            print(allFiles![1])
            let pathConfig = allFiles?[1]
            readFileConfig(path: pathConfig)
            do {
                try configText.write(toFile: pathConfig!, atomically: true, encoding: .utf8)
            } catch {
                print("jjjjjjopa")
            }
            conf_path_set(path)
            myPath = path
            print("gggggggghghghgh - \(path)")
        }

        guard conf_configure() == 0 else { return }

        let allFiles = contentsOfDirectoryAtPath(path: myPath)
        print("Все файлы в каталоге - \(String(describing: allFiles))")
//        let allFiles = contentsOfDirectoryAtPath(path: myPath)
//        print("Все файлы в каталоге - \(String(describing: allFiles))")
//        print("Второй файл в каталоге:")
//        print(allFiles![1])
//        let pathConfig = allFiles?[1]
        //readFileConfig(path: pathConfig)
        
        // Initialize the SIP stack.
        guard baresip_init(conf_config()) == 0 else { return }
        guard ua_init("SIP", 1, 1, 1) == 0 else { return }

        // Load modules.
        guard conf_modules() == 0 else { return }

        let addr = "<sip:999999@192.168.0.148;transport=udp>;auth_pass=999999;answermode=manual;video_codecs=h264"
        //let addr = "<sip:999999@192.168.0.148;transport=udp>;auth_pass=999999;answermode=auto"//stunserver=turn:stun.studio.link;medianat=ice;mediaenc=dtls_srtp;stunuser=xxx;stunpass=xxx"

        // Start user agent.
        guard ua_alloc(&agent, addr) == 0 else { return }
        guard ua_register(agent) == 0 else { return }
        
        uag_event_register({ [self] (userAgent, event, call, prm, arg) in
            print("Ивент - \(event)")
            print(Date())
            if event.rawValue == 1 {
                print("регистрация прошла успешно")
            }
            if event.rawValue == 6 {
                print("callhandler")
            }
            if event.rawValue == 10 {
                print("Call Closed")
            }
            if event.rawValue == 9 {
                //print("Incoming Call")
                print("Входящий вызов!!!!!!!!!!!")
            }
            if event.rawValue == 13 {
                print("идет разговор")
            }
            }, nil)
            
        let registered = ua_isregistered(agent)
        if registered == 0 {
            print("USER 999999@192.168.0.148 REGISTERED!!!!!")
        } else {
            print("USER REGISTERATION FAILED!!!")
        }
        print("*------------")
        //print(call_is_outgoing(self.agent))
        //account_set_answermode(agent, answermode(rawValue: 2))
        print(account_answermode(self.agent).rawValue)
        print("------------*")
        DispatchQueue.global(qos: .userInitiated).async {
            re_main(nil)
        }
    }
    
    func printIncomingCall(mess: String) {
        StateCallLabel.text = mess
    }
    
    @IBAction func closeConnectionButt(_ sender: Any) {
        self.close(agent: agent!)
        test()
    }
    
    @IBAction func answercallButt(_ sender: Any) {
        //ua_answer(agent, nil, VIDMODE_OFF)
        ua_answer(agent, nil, VIDMODE_ON)
    }
}

extension ViewController{
    func startEncode(){
        let aVCaptureSession =  AVCaptureSession()
        if aVCaptureSession.canSetSessionPreset(AVCaptureSession.Preset.vga640x480){
           aVCaptureSession.sessionPreset = AVCaptureSession.Preset.vga640x480
        }
        let videoDevices = AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified).devices//  AVCaptureDevice.devices(for: AVMediaTypeVideo)
        var videoInputDevice =  AVCaptureDevice.default(for: AVMediaType.video)//视频输入设备
        videoDevices.forEach({ (aVCaptureDevice) in
            if aVCaptureDevice.position == .back {
                videoInputDevice = aVCaptureDevice
            }
        })
        
        if videoInputDevice?.isTorchAvailable ?? false {
            do {
                try videoInputDevice?.lockForConfiguration()
                videoInputDevice?.torchMode = .off
                videoInputDevice?.unlockForConfiguration()
            } catch {
                
            }
        }
        ///input
        if let curVideoInputDevice = videoInputDevice {
            if let videoInput = try? AVCaptureDeviceInput(device: curVideoInputDevice) {
                if aVCaptureSession.canAddInput(videoInput) {
                    aVCaptureSession.addInput(videoInput)
                    let aVCaptureVideoPreviewLayer  = AVCaptureVideoPreviewLayer(session: aVCaptureSession)
                    aVCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    self.decodeView.layer.addSublayer(aVCaptureVideoPreviewLayer)
                    aVCaptureVideoPreviewLayer.frame = self.decodeView.bounds
                }
            }
        }
        aVCaptureSession.outputs.forEach { (output) in
            aVCaptureSession.removeOutput(output)
        }
        //output
        let videoOutPut =  AVCaptureVideoDataOutput()
        videoOutPut.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        if aVCaptureSession.canAddOutput(videoOutPut) {
            aVCaptureSession.addOutput(videoOutPut)
            //如果没有相机权限，执行如下会闪退 videoOutPut.connection(withMediaType: AVMediaTypeVideo).videoOrientation = .portrait
            let outPutAVCaptureConnection = videoOutPut.connection(with: AVMediaType.video)
            outPutAVCaptureConnection?.videoOrientation = .portrait
        }
        /*let aVCaptureVideoPreviewLayer  = AVCaptureVideoPreviewLayer(session: aVCaptureSession)
        aVCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.viewMy.layer.addSublayer(aVCaptureVideoPreviewLayer)
        aVCaptureVideoPreviewLayer.frame = self.viewMy.bounds*/
        
        if !aVCaptureSession.isRunning {
            aVCaptureSession.startRunning()
        }
        
        vTCompressionH264.width = 480
        vTCompressionH264.height = 640
        vTCompressionH264.fps = 10
        vTCompressionH264.delegate = self
        vTCompressionH264.prepareToEncodeFrames()
    }
    
    func stopEncode(){
        if  let aVCaptureVideoPreviewLayer = self.viewMy.layer.sublayers?[0] as? AVCaptureVideoPreviewLayer{
            aVCaptureVideoPreviewLayer.session?.stopRunning()
        }
        vTCompressionH264.invalidate()
    }
}

extension ViewController:VTCompressionH264EncodeDelegate{
    func dataCallBack(_ data: Data!, frameType: FrameType) {
        let byteHeader:[UInt8] = [0,0,0,1]
        var byteHeaderData = Data(byteHeader)
        byteHeaderData.append(data)
        vTCompressionH264Decode.decode(byteHeaderData)
    }
    
    func spsppsDataCallBack(_ sps: Data!, pps: Data!) {
        let spsbyteHeader:[UInt8] = [0,0,0,1]
        var spsbyteHeaderData = Data(spsbyteHeader)
        var ppsbyteHeaderData = Data(spsbyteHeader)
        spsbyteHeaderData.append(sps)
        ppsbyteHeaderData.append(pps)
        vTCompressionH264Decode.decode(spsbyteHeaderData)
        vTCompressionH264Decode.decode(ppsbyteHeaderData)
    }
}

extension ViewController:VTCompressionH264DecodeDelegate{
    func imageBufferCallBack(_ imageBuffer: CVImageBuffer) {
        //aAPLEAGLLayer.pixelBuffer = imageBuffer
    }
}

extension ViewController:AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureFileOutputRecordingDelegate{
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        vTCompressionH264.encode(by: sampleBuffer)
    }
}
