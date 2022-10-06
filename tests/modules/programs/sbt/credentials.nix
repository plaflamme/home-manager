{ config, lib, pkgs, ... }:

with lib;

let
  credentials = [
    {
      realm = "Sonatype Nexus Repository Manager";
      host = "example.com";
      user = "user";
      passwordCommand = "echo password";
    }
    {
      realm = "Sonatype Nexus Repository Manager X";
      host = "v2.example.com";
      user = "user1";
      passwordCommand = "echo password1";
    }
  ];
  expectedCredentialsSbt = pkgs.writeText "credentials.sbt" ''
    import scala.sys.process._
    lazy val credential_41dbb854a44088597c878eb68ff6c354e1c6fbe6792fcebdfa9554ce293bf01a = "echo password".!!.trim
    credentials += Credentials("Sonatype Nexus Repository Manager", "example.com", "user", credential_41dbb854a44088597c878eb68ff6c354e1c6fbe6792fcebdfa9554ce293bf01a)
    lazy val credential_f766e5b43bdc3a1e67921a994b9ef72089c4857928a3f5b50620ced575c33f10 = "echo password1".!!.trim
    credentials += Credentials("Sonatype Nexus Repository Manager X", "v2.example.com", "user1", credential_f766e5b43bdc3a1e67921a994b9ef72089c4857928a3f5b50620ced575c33f10)
  '';
  credentialsSbtPath = ".sbt/1.0/credentials.sbt";
in {
  config = {
    programs.sbt = {
      enable = true;
      credentials = credentials;
      package = pkgs.writeScriptBin "sbt" "";
    };

    nmt.script = ''
      assertFileExists "home-files/${credentialsSbtPath}"
      assertFileContent "home-files/${credentialsSbtPath}" "${expectedCredentialsSbt}"
    '';
  };
}
