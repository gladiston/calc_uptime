unit view.main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, DateTimePicker;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnCalcular: TBitBtn;
    cbox_data_atual: TCheckBox;
    edtDataReferencia: TDateTimePicker;
    edtDias: TEdit;
    edtHoras: TEdit;
    edtMinutos: TEdit;
    edtSegundos: TEdit;
    gbUptime: TGroupBox;
    gb_apartir_de: TGroupBox;
    gb_dias: TGroupBox;
    gb_horas: TGroupBox;
    gb_minutos: TGroupBox;
    gb_segs: TGroupBox;
    gb_tag: TGroupBox;
    memoResultados: TMemo;
    pnlCalcular_Sair: TPanel;
    tagname: TEdit;
    Timer_Update_DataReferencia: TTimer;
    procedure btnCalcularClick(Sender: TObject);
    procedure cbox_data_atualChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tagnameExit(Sender: TObject);
    procedure Timer_Update_DataReferenciaTimer(Sender: TObject);
  private
    FConfigFile: String;
    procedure SetConfigFile(AValue: String);

  public
  published
    property ConfigFile:String read FConfigFile write SetConfigFile;
  end;

var
  Form1: TForm1;

implementation
uses
  DateUtils,
  Inifiles;

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnCalcularClick(Sender: TObject);
var
  iDataReferencia:TDateTime;
  iDataResultado:TDateTime;
  sResultado:String;
  iDias:Integer;
  iHoras:Integer;
  iMinutos:Integer;
  iSegundos:Integer;
  sTagName:String;
  sMsg_Err:String;
  MyIni:TIniFile;
begin
  sMsg_Err:=emptyStr;
  sResultado:=emptyStr;
  sTagName:=Trim(tagname.text);

  iDataReferencia:=edtDataReferencia.DateTime;
  if cbox_data_atual.Checked then
    iDataReferencia:=now;

  iDias:=StrToIntDef(edtDias.Text, -1);
  if (sMsg_Err=emptyStr) and (iDias<0) then
    sMsg_Err:='A quantidade de dias de uptime é inválida';
  iHoras:=StrToIntDef(edtHoras.Text, -1);
  if (sMsg_Err=emptyStr) and ((iHoras<0) or (iHoras>23)) then
    sMsg_Err:='A quantidade de horas de uptime é inválida';
  iMinutos:=StrToIntDef(edtMinutos.Text, -1);
  if (sMsg_Err=emptyStr) and ((iMinutos<0) or (iMinutos>59)) then
    sMsg_Err:='A quantidade de minutos de uptime é inválida';
  iSegundos:=StrToIntDef(edtSegundos.Text, -1);
  if (sMsg_Err=emptyStr) and ((iSegundos<0) or (iSegundos>59)) then
    sMsg_Err:='A quantidade de segundos de uptime é inválida';

  if (iDias=0) and
     (iHoras=0) and
     (iMinutos=0) and
     (iSegundos=0) then
     sMsg_Err:='O uptime informado é inválido.';
  if sMsg_Err=emptyStr then
  begin
    iDataResultado:=iDataReferencia;
    if iDias>0 then
    begin
      iDataResultado:=IncDay(iDataResultado, (iDias*-1));
    end;
    if iHoras>0 then
    begin
      iDataResultado:=IncHour(iDataResultado, (iHoras*-1));
    end;
    if iMinutos>0 then
    begin
      iDataResultado:=IncMinute(iDataResultado, (iMinutos*-1));
    end;
    if iSegundos>0 then
    begin
      iDataResultado:=IncSecond(iDataResultado, (iSegundos*-1));
    end;
    sResultado:= sTagName+':';
    if cbox_data_atual.Checked then
      sResultado:= sResultado+' data atual -'
    else
      sResultado:= sResultado+' '+FormatDateTime('dd/mm/yyyy hh:nn:ss', iDataReferencia)+' -';

    sResultado:= sResultado+' '+
      edtDias.Text+'d '+
      edtHoras.Text+'h '+
      edtMinutos.Text+'m '+
      edtSegundos.Text+'s =';

    sResultado:= sResultado+' '+FormatDateTime('dd(ddd)/mm/yyyy hh:nn:ss', iDataResultado);

  end;
  if sMsg_Err=emptyStr then
  begin
    memoResultados.Lines.Add(sResultado);
    MyIni:=TInifile.Create(ConfigFile);
    try
      Myini.WriteInteger(sTagName, 'd', iDias);
      Myini.WriteInteger(sTagName, 'h', iHoras);
      Myini.WriteInteger(sTagName, 'm', iMinutos);
      Myini.WriteInteger(sTagName, 's', iSegundos);
    finally
    end;

  end
  else
  begin
    memoResultados.Lines.Add(
      'Não foi possivel calcular:'+sLineBreak+
      sMsg_Err);
  end;
end;

procedure TForm1.cbox_data_atualChange(Sender: TObject);
begin
  if cbox_data_atual.Checked then
  begin
    edtDataReferencia.Enabled:=false;
    Timer_Update_DataReferencia.Enabled:=true;
  end
  else
  begin
    edtDataReferencia.Enabled:=true;
    Timer_Update_DataReferencia.Enabled:=false;
    if edtDataReferencia.CanFocus then
      edtDataReferencia.SetFocus;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  edtDataReferencia.dateTime:=now;
  cbox_data_atual.Checked:=true;
  Timer_Update_DataReferencia.Enabled:=false;
  ConfigFile:=ChangeFileExt(ExtractFileName(Application.ExeName),'.ini');
  Caption:='Calculadora de uptime';
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  cbox_data_atualChange(Sender);
end;

procedure TForm1.tagnameExit(Sender: TObject);
var
  iDias:Integer;
  iHoras:Integer;
  iMinutos:Integer;
  iSegundos:Integer;
  sTagName:String;
  MyIni:TInifile;
begin
  sTagName:=Trim(tagname.Text);
  tagname.Text:=sTagName;
  iDias:=StrToIntDef(edtDias.Text, 0);
  iHoras:=StrToIntDef(edtHoras.Text, 0);
  iMinutos:=StrToIntDef(edtMinutos.Text, 0);
  iSegundos:=StrToIntDef(edtSegundos.Text, 0);
  if (iDias<=0) and
     (iHoras<=0) and
     (iMinutos<=0) and
     (iSegundos<=0) then
  begin
    MyIni:=TInifile.Create(ConfigFile);
    try
      iDias:=Myini.ReadInteger(sTagName, 'd', iDias);
      iHoras:=Myini.ReadInteger(sTagName, 'h', iHoras);
      iMinutos:=Myini.ReadInteger(sTagName, 'm', iMinutos);
      iSegundos:=Myini.ReadInteger(sTagName, 's', iSegundos);
      edtDias.Text:=IntToStr(iDias);
      edtHoras.Text:=IntToStr(iHoras);
      edtMinutos.Text:=IntToStr(iMinutos);
      edtSegundos.Text:=IntToStr(iSegundos);
    finally
    end;
    MyIni.Free;
  end;
end;

procedure TForm1.Timer_Update_DataReferenciaTimer(Sender: TObject);
begin
  Timer_Update_DataReferencia.Enabled:=false;
  if cbox_data_atual.Checked then
  begin
    edtDataReferencia.Enabled:=false;
    edtDataReferencia.DateTime:=now;
    Timer_Update_DataReferencia.Enabled:=true;
  end;
  Timer_Update_DataReferencia.Enabled:=true;
end;

procedure TForm1.SetConfigFile(AValue: String);
begin
  if FConfigFile=AValue then Exit;
  FConfigFile:=AValue;
end;

end.

