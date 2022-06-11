unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Process, LCLTranslator, DefaultTranslator, IniPropStorage;

type

  { TMainForm }

  TMainForm = class(TForm)
    ImageList1: TImageList;
    IniPropStorage1: TIniPropStorage;
    Label1: TLabel;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure WarpRegister;
    procedure StartProcess(command: string);
    procedure ToolButton1Click(Sender: TObject);
  private

  public

  end;

resourcestring
  ConnectionIsEncrypted = 'connection is encrypted';
  WaitingForConnection = 'waiting for connection...';
  ConnectionAttempt = 'connection attempt...';
  Disconnection = 'disconnection...';

var
  Registered: boolean; //Флаг регистрации WARP
  MainForm: TMainForm;

implementation

uses PingTRD;

{$R *.lfm}

{ TMainForm }

//Регистрация скриптом "register.sh" из "autoexpect warp-cli register" (пакет expect)
procedure TMainForm.WarpRegister;
var
  S: TStringList;
  ExProcess: TProcess;
begin
  S := TStringList.Create;
  ExProcess := TProcess.Create(nil);
  try
    ExProcess.Executable := '/bin/bash';
    ExProcess.Parameters.Add('-c');
    ExProcess.Parameters.Add(
      '[[ -n $(grep yes ~/.local/share/warp/accepted-tos.txt) ]] || "' +
      ExtractFilePath(ParamStr(0)) + 'register.sh"; ' +
      'grep yes ~/.local/share/warp/accepted-tos.txt');

    ExProcess.Options := ExProcess.Options + [poUsePipes];  //poWaitOnExit,
    ExProcess.Execute;

    S.LoadFromStream(ExProcess.Output);

    if S.Count <> 0 then Registered := True
    else
      Registered := False;

  finally
    S.Free;
    ExProcess.Free;
  end;
end;

//Общая процедура запуска команд (асинхронная)
procedure TMainForm.StartProcess(command: string);
var
  ExProcess: TProcess;
begin
  //  Application.ProcessMessages;
  ExProcess := TProcess.Create(nil);
  try
    ExProcess.Executable := '/bin/bash';
    ExProcess.Parameters.Add('-c');
    ExProcess.Parameters.Add(command);
    //ExProcess.Options := ExProcess.Options + [poWaitOnExit, poUsePipes];

    ExProcess.Execute;

  finally
    ExProcess.Free;
  end;
end;

procedure TMainForm.ToolButton1Click(Sender: TObject);
begin
  Application.ProcessMessages;

  //Если WARP зарегистрирован...
  if Registered then
  begin
    if ToolButton1.ImageIndex = 0 then
    begin
      Label1.Caption := ConnectionAttempt;
      StartProcess(
        'while [[ $(ip -br a | grep CloudflareWARP) ]]; do warp-cli disconnect; sleep 1; done; warp-cli connect');
    end
    else
    begin
      Label1.Caption := Disconnection;
      StartProcess('while [[ $(ip -br a | grep CloudflareWARP) ]]; do warp-cli disconnect; sleep 1; done');
    end;
  end
  else
    //Иначе - попытка регистрации
    WarpRegister;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  FCheckPingThread: TThread;
begin
  MainForm.Caption := Application.Title;

  //Проверка регистрации/регистрация WARP (Registered=False/True)
  WarpRegister;

  IniPropStorage1.IniFileName := GetUserDir + '.config/warpgui.ini';

  //Поток проверки пинга
  FCheckPingThread := CheckPing.Create(False);
  FCheckPingThread.Priority := tpNormal;
end;

end.
