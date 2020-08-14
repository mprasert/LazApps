unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  Grids, StdCtrls, Types;

type

  { TForm1 }

  TForm1 = class(TForm)
    ComboBox1: TComboBox;
    Label1: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    StatusBar1: TStatusBar;
    StringGrid1: TStringGrid;
    procedure ComboBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
      var CanSelect: Boolean);
  private

  public

  end;

var
  Form1: TForm1;

implementation

uses
  windows;

{$R *.lfm}

const
  kStart = $4E00;  // chinese char

{ TForm1 }

procedure TForm1.StringGrid1DrawCell(Sender: TObject; aCol, aRow: Integer;
  aRect: TRect; aState: TGridDrawState);
var
  rct : TRect;
  wchar : WideChar;
begin
  if (ARow=0) then
    begin
      if (ACol>0) then
        begin
          with TStringGrid(Sender) do
            begin
              Canvas.Brush.Color := clBtnFace;
              Canvas.FillRect(aRect);
              Canvas.Font.Name := 'Arial';
              Canvas.Font.Size := 10;
              Canvas.Font.Style := [fsBold];
              Canvas.Font.Color := clmaroon;
              rct := aRect;
              DrawText(Canvas.Handle,
                       PChar(IntToHex(ACol-1,1)),
                       -1,
                       rct,
                       DT_SINGLELINE+DT_VCENTER+DT_CENTER);
            end;
        end;
    end
  else if (ACol=0) then
    begin
      with TStringGrid(Sender) do
        begin
          Canvas.Brush.Color := clBtnFace;
          Canvas.FillRect(aRect);
          Canvas.Font.Name := 'Arial';
          Canvas.Font.Size := 10;
          Canvas.Font.Style := [fsBold];
          Canvas.Font.Color := clTeal;
          rct := aRect;
          DrawText(Canvas.Handle,
                   PChar(IntToHex(kStart+((ARow-1)*16)+Acol,4)),
                   -1,
                   rct,
                   DT_SINGLELINE+DT_VCENTER+DT_CENTER);
        end;
    end
  else
    begin
      with TStringGrid(Sender) do
        begin
          Canvas.Brush.Color := clWhite;
          Canvas.FillRect(aRect);
          Canvas.Font.Name := ComboBox1.Text; // 'Lucida Sans Unicode';
          Canvas.Font.Height := DefaultRowHeight-12;
          Canvas.Font.Style := [fsBold];
          Canvas.Font.Color := $005555DD;

          wchar :=  WideChar($4E00+((ARow-1)*16)+(ACol-1));
          rct := aRect;
          DrawTextW(Canvas.Handle,
                    @wchar,
                    -1,
                    rct,
                    DT_SINGLELINE+DT_VCENTER+DT_CENTER);

        end;
    end;
end;

procedure TForm1.StringGrid1SelectCell(Sender: TObject; aCol, aRow: Integer;
  var CanSelect: Boolean);
begin
  Panel2.Font.Name := ComboBox1.Text;
  Panel2.Font.Height := Panel2.Height - 8;
  Panel2.Caption := UTF8Encode(WideChar($4E00+((ARow-1)*16)+(ACol-1)));
  Label1.Caption := IntToHex($4E00+((ARow-1)*16)+(ACol-1),4);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Label1.Caption := String.Empty;
  ComboBox1.Items.Assign(Screen.Fonts);
  ComboBox1.ItemIndex := ComboBox1.Items.IndexOf('Lucida Sans Unicode');
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  StringGrid1.SetFocus;
  StringGrid1.Invalidate;
end;


end.

