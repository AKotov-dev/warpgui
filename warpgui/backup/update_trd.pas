unit update_trd;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, Forms, Controls, SysUtils, Process;

type
  CheckUpdate = class(TThread)
  private

    { Private declarations }
  protected
    S: TStringList;

    procedure Execute; override;
    procedure StopUpdate;

  end;

implementation

uses unit1;

{ TRD }

//Загрузка/Обновление WARP
procedure CheckUpdate.Execute;
var
  UpdateProcess: TProcess;
begin
  S := TStringList.Create;
  FreeOnTerminate := True; //Уничтожать по завершении
  try
    UpdateProcess := TProcess.Create(nil);

    UpdateProcess.Executable := 'bash';
    UpdateProcess.Parameters.Add('-c');
    UpdateProcess.Options := [poUsePipes, poWaitOnExit];

    UpdateProcess.Parameters.Add(
      '[[ $(systemctl is-active warp-update) == active ]] || systemctl --user start warp-update');

    //Запуск Загрузки/Обновления
    UpdateProcess.Execute;

    //Показать версию WARP
    UpdateProcess.Parameters.Delete(1);
    UpdateProcess.Parameters.Add('warp-cli --version; echo -e "---\nF11 - ' +
    ResetWarpMsg + '\nF12 - ' + EndPointChange + '"');
    UpdateProcess.Execute;

    S.LoadFromStream(UpdateProcess.Output);
    Synchronize(@StopUpdate);
  finally
    S.Free;
    UpdateProcess.Free;
  end;
end;

//Останов обновления
procedure CheckUpdate.StopUpdate;
begin
  //Перечитываем версию в подсказке
  MainForm.StartBtn.Hint := S.Text;
end;

end.
