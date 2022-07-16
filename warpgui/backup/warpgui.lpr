program warpgui;

{$mode objfpc}{$H+}

uses
 {$IFDEF UNIX}
  cthreads,
    {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  Unit1,
  PingTRD { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource := True;
 // Application.HintHidePause := 1000;
  Application.Title := 'warpgui-v0.4';
  Application.Scaled := True;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
