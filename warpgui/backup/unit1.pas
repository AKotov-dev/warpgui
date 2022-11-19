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
    StatusLabel: TLabel;
    ToolBar1: TToolBar;
    StartBtn: TToolButton;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure WarpRegister;
    procedure StartProcess(command: string);
    procedure StartBtnClick(Sender: TObject);

  private

  public

  end;

resourcestring
  ConnectionIsEncrypted = 'connection is encrypted';
  WaitingForConnection = 'waiting for connection...';
  ConnectionAttempt = 'connection attempt...';
  Disconnection = 'disconnection...';
  WarpSVCStatus = 'warp-svc.service is not running!' + sLineBreak +
    sLineBreak + 'systemctl enable warp-svc.service' + sLineBreak +
    'systemctl restart warp-svc.service';
  EndPointChange = 'change endpoint';

var
  Registered: boolean; //Флаг регистрации WARP
  MainForm: TMainForm;

implementation

uses PingTRD, Update_TRD;

{$R *.lfm}

{ TMainForm }


//1. Проверка статуса warp-svc.service (active/inactive)
//2. Регистрация скриптом "register.sh" из "autoexpect warp-cli register" (пакет expect)
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
    ExProcess.Options := [poUsePipes];

    //1. Проверка статуса warp-svc.service
    ExProcess.Parameters.Add('systemctl is-active warp-svc.service');
    ExProcess.Execute;
    S.LoadFromStream(ExProcess.Output);

    if (S[0] <> 'active') and (FileExists('/usr/bin/warp-svc')) then
    begin
      MessageDlg(WarpSVCStatus, mtWarning, [mbOK], 0);
      Application.Terminate;
    end;

    //2. Запуск/Проверка регистрации через expect; если уже зарегистрирован - запроса не будет
    ExProcess.Parameters.Delete(1);
    ExProcess.Parameters.Add(
      '"' + ExtractFilePath(ParamStr(0)) + 'register.sh"; ' +
      'grep yes ~/.local/share/warp/accepted-tos.txt');

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
  ExProcess := TProcess.Create(nil);
  try
    ExProcess.Executable := '/bin/bash';
    ExProcess.Parameters.Add('-c');
    ExProcess.Parameters.Add(command);

    ExProcess.Execute;
  finally
    ExProcess.Free;
  end;
end;

procedure TMainForm.StartBtnClick(Sender: TObject);
begin
  Application.ProcessMessages;

  //Если WARP зарегистрирован...
  if Registered then
  begin
    if StartBtn.ImageIndex = 0 then
    begin
      StatusLabel.Caption := ConnectionAttempt;
      StartProcess(
        'while [[ $(ip -br a | grep CloudflareWARP) ]]; do warp-cli disconnect; sleep 1; done; warp-cli connect');
    end
    else
    begin
      StatusLabel.Caption := Disconnection;
      StartProcess('while [[ $(ip -br a | grep CloudflareWARP) ]]; do warp-cli disconnect; sleep 1; done');
    end;
  end
  else
    //Иначе - попытка регистрации
    WarpRegister;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  FCheckPingThread, FUpdateThread: TThread;
begin
  MainForm.Caption := Application.Title;

  //Проверка регистрации/регистрация WARP (Registered=False/True)
  WarpRegister;

  IniPropStorage1.IniFileName := GetUserDir + '.config/warpgui.ini';

  //Поток проверки пинга
  FCheckPingThread := CheckPing.Create(False);
  FCheckPingThread.Priority := tpNormal;

  //Поток проверки обновлений WARP
  FUpdateThread := CheckUpdate.Create(False);
  FUpdateThread.Priority := tpNormal;
end;

//F12 - Генерация endpoint: 162.159.19(2,3).(1-10):(2048,500,4500)
procedure TMainForm.FormKeyUp(Sender: TObject; var Key: word; Shift: TShiftState);
begin
  if Key = $7B then
  begin
    //Отключить, если подключено
  //  if StatusLabel.Color = clGreen then StartBtn.Click;

  {  StartProcess('a="$(warp-cli settings | grep endpoint | cut -f4 -d" " | cut -f1 -d":" | cut -f4 -d".")"; '
      + '[[ $a == 10 ]] && let a=1 || let a=$a+1; warp-cli set-custom-endpoint 162.159.193.$a:2408'); }

    StartProcess(
      'arr=("500" "4500" "2408"); rand=$[$RANDOM % ${#arr[@]}]; ' +
      'warp-cli set-custom-endpoint 162.159.19$((2 + $RANDOM %2)).$((1 + $RANDOM %10)):${arr[$rand]}');

    if StatusLabel.Color = clRed then StartBtn.Click;
  end;
end;

end.
