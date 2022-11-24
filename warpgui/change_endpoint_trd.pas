unit change_endpoint_trd;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, Forms, Controls, SysUtils, Process;

type
  ChangeEndpoint = class(TThread)
  private

    { Private declarations }
  protected

    procedure Execute; override;
    procedure StartChange;
    procedure StopChange;

  end;

implementation

uses Unit1;

{ TRD }

//Смена endpoint
procedure ChangeEndpoint.Execute;
var
  ChangeProcess: TProcess;
begin
  FreeOnTerminate := True; //Уничтожать по завершении
  try
    //Флаг запуска смены EndPoint/ResetWarp
    StartChangeEndpoint := True;

    Synchronize(@StartChange);

    ChangeProcess := TProcess.Create(nil);
    ChangeProcess.Executable := 'bash';
    ChangeProcess.Parameters.Add('-c');
    ChangeProcess.Options := [poWaitOnExit];

    //Замена EndPoint: останов (5 попыток/секунд), замена, проба подключения (5 попыток/секунд)
    //warp-cli после одиночного connect сам пытается сделать несколько попыток подключения
    //если неудача или окончание спустя 10 сек флаг StartChangeEndpoint = False, поток PingTRD сбрасывает состояние Connecting
    ChangeProcess.Parameters.Add(
      'warp-cli disconnect; i=0; while [[ $(ip -br a | grep CloudflareWARP) ]]; do warp-cli disconnect; sleep 1; ((i++)); [[ $i == 5 ]] && break; done; ' + 'arr=("500" "4500" "2408"); rand=$[$RANDOM % ${#arr[@]}]; ' + 'warp-cli set-custom-endpoint 162.159.19$((2 + $RANDOM %2)).$((1 + $RANDOM %10)):${arr[$rand]}; ' + 'i=0; while [[ -z $(ip -br a | grep CloudflareWARP) ]]; do warp-cli connect; sleep 1; ((i++)); if [[ $i == 5 ]]; then warp-cli disconnect; break; fi; done');

    ChangeProcess.Execute;

  finally
    Synchronize(@StopChange);
    StartChangeEndpoint := False;
    ChangeProcess.Free;
  end;
end;

//---Статус смены EndPoint---
procedure ChangeEndpoint.StartChange;
begin
  MainForm.Caption := EndPointChange + '...';
end;

procedure ChangeEndpoint.StopChange;
begin
  MainForm.Caption := Application.Title;
end;

end.
