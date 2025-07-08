class AwsIotCoreConfig {
  static const String endpoint = 'a2advbzdjbayfo-ats.iot.us-east-2.amazonaws.com';
  static const String clientId = "petsafev1";
  static const String pubTopic = 'esp32/control_reles'; 
  static const String subTopic = 'esp32/datos_esp32'; // 'esp32/datos_esp32'
  static const int port = 8883;
  static const int keepAlivePeriod = 180;
  static const String caPath = 'assets/certs/AmazonRootCA1.pem';
  static const String certPath = 'assets/certs/CertificateFile.pem.crt';
  static const String keyPath = 'assets/certs/privateKey.pem.key';
}