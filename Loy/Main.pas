unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls;

const
  st =  'ปฏิทินแผ่นหมุนนิรันดร์กาล Loy Academy (ลอย ชุนพงษ์ทอง)' + #13#10 +
        'วิธีการใช้งาน ปฏิทินแผ่นหมุนนิรันดร์กาล หาดูได้จากเว็บ YouTube' + #13#10#13#10 +
        'โปรแกรมแผ่นหมุนสำหรับวินโดวส์ 64 บิต (ฟรีแวร์)' + #13#10#13#10 +
        'การใช้งานแป้นพิมพ์' + #13#10#13#10 +
        'ปุ่ม F1 - วิธีใช้งาน' + #13#10 +
        'ปุ่มลูกศร ขึ้น ลง ซ้าย ขวา - เลื่อนแผ่นหมุน' + #13#10 +
        'ปุ่ม Esc - ปิดโปรแกรม';


type

  { TMainForm }

  TMainForm = class(TForm)
    Image1: TImage;
    Image2: TImage;
    PaintBox1: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure PaintBox1Paint(Sender: TObject);
  private
    FAngle : Single;
  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

uses
  LCLType, BGRABitmap, BGRABitmapTypes;

{ TMainForm }

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ClientHeight := 750;
  ClientWidth := 750;
  FAngle := 0.0;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    begin
      Close;
    end
  else if (Key = VK_F1) then
    begin
      ShowMessage(st);
    end
  else if (Key = VK_UP) or (Key = VK_RIGHT) then
    begin
      FAngle := FAngle + 1;
      if FAngle = 360 then FAngle := 0;
      PaintBox1.Repaint;
    end
  else if (Key = VK_DOWN) or (Key = VK_LEFT) then
    begin
      FAngle := FAngle - 1;
      if FAngle = -1 then FAngle := 359;
      PaintBox1.Repaint;
    end;
end;

procedure TMainForm.PaintBox1Paint(Sender: TObject);
var
  bmp, bmp2 : TBGRABitmap;
begin
  bmp := TBGRABitmap.Create(Image1.Picture.Bitmap);
  bmp2 := TBGRABitmap.Create(Image2.Picture.Bitmap);
  try
    bmp.PutImageAngle(bmp.Width/2-0.5,
                      bmp.Height/2-0.5,
                      bmp2,
                      FAngle,
                      bmp2.Width/2-0.5,
                      bmp2.Height/2-0.5);
    bmp.Draw(PaintBox1.Canvas,0,0);
  finally
    bmp.Free;
    bmp2.Free;
  end;
end;

end.

