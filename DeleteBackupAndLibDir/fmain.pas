unit FMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  Buttons;

type

  { TFormMain }

  TFormMain = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Memo1: TMemo;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    SpeedButton1: TSpeedButton;
    StatusBar1: TStatusBar;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    FIniFileName : string;
  public

  end;

var
  FormMain: TFormMain;

implementation

uses
  LazFileUtils, LazStringUtils, FileUtil, IniFiles;

{$R *.lfm}

{ TFormMain }

procedure TFormMain.SpeedButton1Click(Sender: TObject);
var
  n : integer;
begin
  if SelectDirectoryDialog1.Execute then
    begin
      n := ComboBox1.Items.Add(SelectDirectoryDialog1.FileName);
      ComboBox1.ItemIndex := n;
    end;
end;

procedure TFormMain.Button1Click(Sender: TObject);
var
  FStringList : TStringList;
  n, m : integer;
  st : string;
begin
  if DirectoryExistsUTF8(ComboBox1.Text) then
    begin
      Button1.Enabled := False;
      Button2.Enabled := False;
      ComboBox1.Enabled := False;
      SpeedButton1.Enabled := False;
      //
      FStringList := TStringList.Create;
      try
        FindAllDirectories(FStringList,ComboBox1.Text);
        if FStringList.Count > 0 then
          begin
            Memo1.Clear;
            for n := 0 to FStringList.Count - 1 do
              begin
                // check if directory -> backup
                m := Pos('\backup',FStringList[n]);
                if (m > 0) then
                  begin
                    st := Copy(FStringList[n],1,m+6);
                    if DirectoryExistsUTF8(st) then
                      begin
                        st := StringReplace(st,ComboBox1.Text+'\','',[rfReplaceAll]);
                        Memo1.Lines.Add(st);
                      end;
                  end;
                // check if directory -> lib
                m := Pos('\lib',FStringList[n]);
                if (m > 0) then
                  begin
                    st := Copy(FStringList[n],1,m+3);
                    if DirectoryExistsUTF8(st) then
                      begin
                        st := StringReplace(st,ComboBox1.Text+'\','',[rfReplaceAll]);
                        Memo1.Lines.Add(st);
                      end;
                  end;
                Application.ProcessMessages;
              end;  // for
          end;  // if FStringList.Count > 0
      finally
        FStringList.Free;
      end;
      //
      Button1.Enabled := True;
      Button2.Enabled := True;
      ComboBox1.Enabled := True;
      SpeedButton1.Enabled := True;
    end;
end;

procedure TFormMain.Button2Click(Sender: TObject);
var
  st : string;
begin
  Button1.Enabled := False;
  Button2.Enabled := False;
  ComboBox1.Enabled := False;
  SpeedButton1.Enabled := False;
  StatusBar1.SimpleText := '';
  while Memo1.Lines.Count > 0 do
    begin
      st := ComboBox1.Text + '\' + Memo1.Lines[0];
      if DirectoryExistsUTF8(st) then
        begin
          if DeleteDirectory(st,True) then
            begin
              if not RemoveDirUTF8(st) then
                begin
                  StatusBar1.SimpleText := 'Error!';
                  Break;
                end;
            end
          else
            begin
              StatusBar1.SimpleText := 'Error!';
              Break;
            end;
        end
      else
        begin
          Memo1.Lines.Delete(0);
        end;
      Application.ProcessMessages;
    end;  // while
  //
  Button1.Enabled := True;
  Button2.Enabled := True;
  ComboBox1.Enabled := True;
  SpeedButton1.Enabled := True;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  ini : TIniFile;
  st : string;
  i : integer;
begin
  Memo1.Clear;
  FIniFileName := ChangeFileExt(Application.ExeName,'.ini');
  //
  ini := TIniFile.Create(FIniFileName);
  st := ini.ReadString('DIR','init',string.Empty);
  ini.Free;
  if not st.IsEmpty then
    begin
      i := ComboBox1.Items.Add(st);
      ComboBox1.ItemIndex := i;
    end;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
var
  ini : TIniFile;
begin
  ini := TIniFile.Create(FIniFileName);
  try
    if ComboBox1.ItemIndex >= 0 then
      begin
        ini.WriteString('DIR','init',ComboBox1.Text);
      end;
  finally
    ini.Free;
  end;
end;

end.

