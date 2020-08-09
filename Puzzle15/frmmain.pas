unit FrmMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, ExtCtrls,
  Buttons, ExtDlgs;

type

  TBlockPiece = 1..16;
  TPuzzleMode = (pzNone, pzPlaying);

  TBlockRec = record
    Rect     : TRect;
    PieceNum : TBlockPiece;
  end;


  { TForm1 }

  TForm1 = class(TForm)
    OpenPictureDialog1: TOpenPictureDialog;
    PaintBox1: TPaintBox;
    Panel1: TPanel;
    spbNewGame: TSpeedButton;
    spbNum: TSpeedButton;
    spbPic: TSpeedButton;
    spbOpen: TSpeedButton;
    StatusBar1: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1Paint(Sender: TObject);
    procedure spbNewGameClick(Sender: TObject);
    procedure spbNumClick(Sender: TObject);
    procedure spbOpenClick(Sender: TObject);
    procedure spbPicClick(Sender: TObject);
  private
    FBmpBuffer : TBitmap;
    FBmpTemp : TBitmap;
    FBlock : array [1..16] of TBlockRec;
    FSpace : integer;
    FMode : TPuzzleMode;
    procedure RenderBuffer;
    procedure NewGame;
    procedure Swap(var A, B : TBlockPiece);
    procedure CheckFinished;
  public

  end;

var
  Form1: TForm1;

implementation

uses
  Types,      // PtInRect
  LCLType,    // vk_right
  LCLIntf;    // StretchBlt

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormResize(Sender: TObject);
var
  w, h, x, y : integer;
begin
  //if (ClientWidth < 326)  then ClientWidth := 326;    // 320
  //if (ClientHeight < 310) then ClientHeight := 310;   // 240

  if (ClientWidth - 6) mod 4 > 0 then
    ClientWidth := 6+((ClientWidth - 6) div 4)*4;

  if (ClientHeight - 70) mod 4 > 0 then
    ClientHeight := 70+((ClientHeight - 70) div 4)*4;

  with FBmpBuffer do
    begin
      Width := PaintBox1.Width;
      Height := PaintBox1.Height;

    end;

  w := PaintBox1.Width div 4;
  h := PaintBox1.Height div 4;

  for y := 1 to 4 do
    for x := 1 to 4 do
      begin
        FBlock[4*(y-1)+x].Rect := Rect(w*(x-1),h*(y-1),w*x,h*y);
      end;

  RenderBuffer;

  //Caption := IntToStr(PaintBox1.Width) + ' x ' +IntToStr(PaintBox1.Height);
end;

procedure TForm1.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  n : integer;
  key : word;
begin
  for n := 1 to 16 do
    if PtInRect(FBlock[n].Rect,Point(x,y)) then
      begin
        if      (n = FSpace-1) then key := vk_right
        else if (n = FSpace+1) then key := vk_left
        else if (n = FSpace-4) then key := vk_down
        else if (n = FSpace+4) then key := vk_up;

        FormKeyDown(self,key,shift);
        Break;
      end;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  TPaintBox(Sender).Canvas.Draw(0,0,FBmpBuffer);
end;

procedure TForm1.spbNewGameClick(Sender: TObject);
begin
  NewGame;
  RenderBuffer;
  PaintBox1.Repaint;
end;

procedure TForm1.spbNumClick(Sender: TObject);
begin
  RenderBuffer;
  PaintBox1.Repaint;
end;

procedure TForm1.spbOpenClick(Sender: TObject);
var
  pic : TPicture;
begin
  if OpenPictureDialog1.Execute then
    begin
      pic := TPicture.Create;
      try
        pic.LoadFromFile(OpenPictureDialog1.FileName);
        if (FBmpTemp = nil) then
          begin
            FBmpTemp := TBitmap.Create;
            FBmpTemp.PixelFormat := pf24bit;
          end;
        with FBmpTemp do
          begin
            Width := FBmpBuffer.Width;
            Height := FBmpBuffer.Height;
            Canvas.StretchDraw(Rect(0,0,Width,Height),pic.Graphic);
          end;
        if spbPic.Down then
          begin
            RenderBuffer;
            PaintBox1.Repaint;
          end;
      finally
        pic.Free;
      end;
    end
end;

procedure TForm1.spbPicClick(Sender: TObject);
var
  pic : TPicture;
begin
  if (FBmpTemp = nil) then
    begin
      if OpenPictureDialog1.Execute then
        begin
          pic := TPicture.Create;
          try
            pic.LoadFromFile(OpenPictureDialog1.FileName);
            FBmpTemp := TBitmap.Create;
            with FBmpTemp do
              begin
                PixelFormat := pf24bit;
                Width := FBmpBuffer.Width;
                Height := FBmpBuffer.Height;
                Canvas.StretchDraw(Rect(0,0,Width,Height),pic.Graphic);
              end;
            RenderBuffer;
            PaintBox1.Repaint;
          finally
            pic.Free;
          end;
        end
      else
        begin
          spbNum.Down := true;
        end;
    end
  else
    begin
      RenderBuffer;
      PaintBox1.Repaint;
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  n : integer;
begin
  Caption := 'Puzzle 15 - Prasert M.Soparut';

  PaintBox1.ControlStyle := PaintBox1.ControlStyle + [csOpaque];

  FBmpBuffer := TBitmap.Create;
  with FBmpBuffer do
    begin
      PixelFormat := pf24bit;
      //Width := PaintBox1.Width;
      //Height := PaintBox1.Height;
    end;

  FBmpTemp := nil;

  for n := 1 to 16 do FBlock[n].PieceNum := n;
  FSpace := 16;

  FMode := pzNone;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FBmpBuffer.Free;
  if Assigned(FBmpTemp) then FBmpTemp.Free;
end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (FMode = pzNone) then Exit;

  if key = VK_UP then
    begin
      if FSpace in [1,2,3,4,5,6,7,8,9,10,11,12] then
        begin
          Swap(FBlock[FSpace].PieceNum,FBlock[FSpace+4].PieceNum);
          Inc(FSpace,4);
          RenderBuffer;
          PaintBox1.Repaint;
          CheckFinished;
        end
      else Beep;
    end
  else if key = VK_DOWN then
    begin
      if FSpace in [5,6,7,8,9,10,11,12,13,14,15,16] then
        begin
          Swap(FBlock[FSpace].PieceNum,FBlock[FSpace-4].PieceNum);
          Dec(FSpace,4);
          RenderBuffer;
          PaintBox1.Repaint;
          CheckFinished;
        end
      else Beep;
    end
  else if key = VK_RIGHT then
    begin
      if FSpace in [2,3,4,6,7,8,10,11,12,14,15,16] then
        begin
          Swap(FBlock[FSpace].PieceNum,FBlock[FSpace-1].PieceNum);
          Dec(FSpace);
          RenderBuffer;
          PaintBox1.Repaint;
          CheckFinished;
        end
      else Beep;
    end
  else if key = VK_LEFT then
    begin
      if FSpace in [1,2,3,5,6,7,9,10,11,13,14,15] then
        begin
          Swap(FBlock[FSpace].PieceNum,FBlock[FSpace+1].PieceNum);
          Inc(FSpace);
          RenderBuffer;
          PaintBox1.Repaint;
          CheckFinished;
        end
      else Beep;
    end;
end;

procedure TForm1.RenderBuffer;
var
  n, w, h, a, b, ww, hh : integer;
  piece : TBlockPiece;
  rct : TRect;
  st : string;
begin
  with FBmpBuffer, Canvas do
    begin
      if spbPic.Down then
        begin
          w := FBmpTemp.Width div 4;
          h := FBmpTemp.Height div 4;
        end;

      for n := 1 to 16 do
        begin
          if (FBlock[n].PieceNum = 16) then
            begin
              Brush.Color := clMedGray;
              Pen.Color := clGray;
              Rectangle(FBlock[n].Rect);
            end
          else
            begin
              rct := FBlock[n].Rect;
              piece := FBlock[n].PieceNum;
              if (piece in [1,5,9,13]) then a := 0
              else if (piece in [2,6,10,14]) then a := w
              else if (piece in [3,7,11,15]) then a := w * 2
              else if (piece in [4,8,12,16]) then a := w * 3;

              if (piece in [1,2,3,4]) then b := 0
              else if (piece in [5,6,7,8]) then b := h
              else if (piece in [9,10,11,12]) then b := h * 2
              else if (piece in [13,14,15,16]) then b := h * 3;

              if spbNum.Down then
                begin
                  Font.Name := 'Default'; //'Tahoma';
                  Font.Color := clBlack;
                  Font.Size := 16;
                  Brush.Color := clSilver;
                  Pen.Color := clGray;
                  Rectangle(rct);
                  st := IntToStr(piece);

                  GetTextSize(st,ww,hh);
                  TextOut(rct.Left+((rct.Right-rct.Left-ww) div 2),
                          rct.Top+((rct.Bottom-rct.Top-hh) div 2),
                          st);
                end
              else // if spbPic.Down then
                begin
                  StretchBlt(FBmpBuffer.Canvas.Handle,
                             rct.Left,
                             rct.Top,
                             rct.Right - rct.Left,
                             rct.Bottom - rct.Top,
                             FBmpTemp.Canvas.Handle,
                             a, b, w, h,
                             SRCCOPY);
                  Brush.Color := clGray;
                  FrameRect(rct);
                  //
                  Font.Name := 'Default'; //'Tahoma';
                  Font.Color := clBlack;
                  Font.Size := 12;
                  Brush.Color := clBtnFace;
                  TextOut(rct.Left + 4, rct.Top + 4,IntTostr(piece));
                end;
            end;
        end;
    end;
end;

procedure TForm1.NewGame;
var
  n, i : integer;
begin
  if (FMode <> pzNone) then
    begin
      n := MessageDlg('Warning !'+#13#13+
                      'Do you want to start new game ?',
                      mtWarning,
                      mbYesNoCancel,
                      0);
      if (n <> mrYes) then Exit;
    end;

  // reset table
  for i := 1 to 16 do FBlock[i].PieceNum := i;
  FSpace := 16;

  Randomize;
  // swap block
  for i := 0 to 2000 do
    begin
      if (FSpace=1) then  // move right down
        begin
          n := Random(100) mod 2;
          case n of
            0 : begin // move right
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace+1].PieceNum);
                  Inc(FSpace);
                end;
            1 : begin // move down
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace+4].PieceNum);
                  Inc(FSpace,4);
                end;
          end;
        end
      else if (FSpace in [2,3]) then  // move left right down
        begin
          n := Random(100) mod 3;
          case n of
            0 : begin // move left
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace-1].PieceNum);
                  Dec(FSpace);
                end;
            1 : begin // move right
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace+1].PieceNum);
                  Inc(FSpace);
                end;
            2 : begin // move down
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace+4].PieceNum);
                  Inc(FSpace,4);
                end;
          end;
        end
      else if (FSpace=4) then  // move left down
        begin
          n := Random(100) mod 2;
          case n of
            0 : begin // move left
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace-1].PieceNum);
                  Dec(FSpace);
                end;
            1 : begin // move down
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace+4].PieceNum);
                  Inc(FSpace,4);
                end;
          end;
        end
      else if (FSpace in [5,9]) then  // move right top down
        begin
          n := Random(100) mod 3;
          case n of
            0 : begin // move right
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace+1].PieceNum);
                  Inc(FSpace);
                end;
            1 : begin // move top
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace-4].PieceNum);
                  Dec(FSpace,4);
                end;
            2 : begin // move down
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace+4].PieceNum);
                  Inc(FSpace,4);
                end;
          end;
        end
      else if (FSpace in [6,7,10,11]) then  // move left right top down
        begin
          n := Random(100) mod 4;
          case n of
            0 : begin // move left
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace-1].PieceNum);
                  Dec(FSpace);
                end;
            1 : begin // move right
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace+1].PieceNum);
                  Inc(FSpace);
                end;
            2 : begin // move top
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace-4].PieceNum);
                  Dec(FSpace,4);
                end;
            3 : begin // move down
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace+4].PieceNum);
                  Inc(FSpace,4);
                end;
          end;
        end
      else if (FSpace in [8,12]) then  // move left top down
        begin
          n := Random(100) mod 3;
          case n of
            0 : begin // move left
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace-1].PieceNum);
                  Dec(FSpace);
                end;
            1 : begin // move top
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace-4].PieceNum);
                  Dec(FSpace,4);
                end;
            2 : begin // move down
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace+4].PieceNum);
                  Inc(FSpace,4);
                end;
          end;
        end
      else if (FSpace=13) then  // move right top
        begin
          n := Random(100) mod 2;
          case n of
            0 : begin // move right
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace+1].PieceNum);
                  Inc(FSpace);
                end;
            1 : begin // move top
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace-4].PieceNum);
                  Dec(FSpace,4);
                end;
          end;
        end
      else if (FSpace in [14,15]) then  // move left right top
        begin
          n := Random(100) mod 3;
          case n of
            0 : begin // move left
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace-1].PieceNum);
                  Dec(FSpace);
                end;
            1 : begin // move right
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace+1].PieceNum);
                  Inc(FSpace);
                end;
            2 : begin // move top
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace-4].PieceNum);
                  Dec(FSpace,4);
                end;
          end;
        end
      else if (FSpace=16) then  // move left top
        begin
          n := Random(100) mod 2;
          case n of
            0 : begin // move left
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace-1].PieceNum);
                  Dec(FSpace);
                end;
            1 : begin // move top
                  Swap(FBlock[FSpace].PieceNum,FBlock[FSpace-4].PieceNum);
                  Dec(FSpace,4);
                end;
          end;
        end;
    end;
  //
  FMode := pzPlaying;
end;

procedure TForm1.Swap(var A, B: TBlockPiece);
var
  i : TBlockPiece;
begin
  i := A;
  A := B;
  B := i;
end;

procedure TForm1.CheckFinished;
var
  i : integer;
begin
  for i := 1 to 16 do if (FBlock[i].PieceNum <> i) then Exit;

  Fmode := pzNone;
  ShowMessage('O.K.');
end;

end.

