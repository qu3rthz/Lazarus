unit jvCSVBase;

{$MODE Delphi}

interface

uses
  LclIntf, lResources, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
   stdctrls,extctrls,buttons, PropEdits;

type
  TonCursorChanged=procedure (Sender:Tobject;NameValues:TstringList;Fieldcount:integer) of object;
  TjvCSVBase = class(TComponent)
  private
    { Private declarations }
   DBOpen:boolean;
   DB:Tstringlist;
   DBRecord:TStringlist;
   DBFields:TStringlist;
   DBCursor:integer;
   FonCursorChanged: TonCursorChanged;
   FCSVFileName: string;
   FCSVFieldNames: TStringlist;
   procedure SetonCursorChanged(const Value: TonCursorChanged);
   procedure DoCursorChange;
    procedure SetCSVFileName(const Value: string);
    procedure SetCSVFieldNames(const Value: TStringlist);
    procedure DisPlayFields(NameValues: TStringlist);
  protected
    { Protected declarations }
    procedure CursorChanged(NameValues:TStringList;FieldCount:integer);
  public
    { Public declarations }
    constructor Create(AOwner:TComponent);override;
    destructor Destroy; override;
    procedure DataBaseCreate(aFile:string;FieldNames:TStringList);
    procedure DataBaseOpen(AFile:string);
    procedure DataBaseClose;
    procedure DataBaseRestructure(aFile:string;Fieldnames:TstringList);
    procedure RecordNew;
    procedure RecordGet(var NameValues:TstringList);
    procedure RecordSet(NameValues:TStringList);
    procedure RecordDelete;
    function  RecordNext:boolean;
    function  RecordPrevious:boolean;
    function  RecordFirst: boolean;
    function  RecordLast: boolean;
    procedure RecordPost;
    function  RecordFind(Atext:string):boolean;
    procedure DisPlay;
  published
    { Published declarations }
    property  CSVFileName:string read FCSVFileName write SetCSVFileName;
    property  CSVFieldNames:TStringlist read FCSVFieldNames write SetCSVFieldNames;
    property  onCursorChanged:TonCursorChanged read FonCursorChanged write SetonCursorChanged;
  end;

  TjvCSVEdit=class(TEdit)
  private
    FCSVDataBase: TjvCSVBase;
    FCSVField: string;
    procedure SetCSVDataBase(const Value: TjvCSVBase);
    procedure SetCSVField(const Value: string);
  protected
    procedure Notification(Acomponent:TComponent; Operation:TOperation);override;
  public
  published
   property CSVDataBase:TjvCSVBase read FCSVDataBase write SetCSVDataBase;
   property CSVField:string read FCSVField write SetCSVField;
  end;



  TjvCSVComboBox=class(TComboBox)
  private
    FCSVField: string;
    FCSVDataBase: TjvCSVBase;
    procedure SetCSVDataBase(const Value: TjvCSVBase);
    procedure SetCSVField(const Value: string);
  protected
    procedure Notification(Acomponent:TComponent; Operation:TOperation);override;
  public
  published
   property CSVDataBase:TjvCSVBase read FCSVDataBase write SetCSVDataBase;
   property CSVField:string read FCSVField write SetCSVField;
  end;

  TjvCSVCheckBox=class(TCheckBox)
  private
    FCSVField: string;
    FCSVDataBase: TjvCSVBase;
    procedure SetCSVDataBase(const Value: TjvCSVBase);
    procedure SetCSVField(const Value: string);
  protected
    procedure Notification(Acomponent:TComponent; Operation:TOperation);override;
  public
  published
   property CSVDataBase:TjvCSVBase read FCSVDataBase write SetCSVDataBase;
   property CSVField:string read FCSVField write SetCSVField;
  end;

  TjvCSVLabel=class(TLabel)
  private
    FCSVDataBase: TjvCSVBase;
    FCSVField: string;
    procedure SetCSVDataBase(const Value: TjvCSVBase);
    procedure SetCSVField(const Value: string);
  protected
    procedure Notification(Acomponent:TComponent; Operation:TOperation);override;
  public
  published
   property CSVDataBase:TjvCSVBase read FCSVDataBase write SetCSVDataBase;
   property CSVField:string read FCSVField write SetCSVField;
  end;


  TjvCSVNavigator=class(TCustomControl)
  private
  fPath:string;
   FbtnFirst:TSpeedButton;
   FbtnPrevious:TspeedButton;
   FbtnFind:TSpeedButton;
   FbtnNext:TSpeedButton;
   FbtnLast:TSpeedbutton;
   FbtnAdd:TSpeedbutton;
   FbtnDelete:TSpeedButton;
   FbtnPost:TSpeedButton;
   FbtnRefresh:TSpeedButton;
    FCSVDataBase: TjvCSVBase;
   procedure CreateButtons;
   procedure btnFirstClick(sender:TObject);
   procedure btnPreviousClick(sender:TObject);
   procedure btnFindClick(sender:TObject);
   procedure btnNextClick(sender:TObject);
   procedure btnLastClick(sender:TObject);
   procedure btnAddClick(sender:TObject);
   procedure btnDeleteClick(sender:TObject);
   procedure btnPostClick(sender:TObject);
   procedure btnRefreshClick(sender:TObject);
    procedure SetCSVDataBase(const Value: TjvCSVBase);

  protected
    procedure Notification(Acomponent:TComponent; Operation:TOperation);override;
  public
   constructor create (AOwner:Tcomponent);override;
   destructor  destroy;override;
   procedure CreateWnd;override;
   procedure Resize;override;
  published
   property CSVDataBase:TjvCSVBase read FCSVDataBase write SetCSVDataBase;
  end;

  TCSVFileNameProperty= class (TStringProperty)
   public
    function GetAttributes:TPropertyattributes; override;
    procedure Edit;override;
   end;

   TCSVFieldProperty=class(TStringProperty)
   public
    function GetAttributes:TPropertyAttributes;override;
    procedure GetValues(Proc: TGetStrProc);override;
   end;
procedure Register;


implementation

{.$R jvCSVBase}

procedure Register;
begin
  RegisterComponents('Jans 2', [TjvCSVBase, TjvCSVEdit, TjvCSVLabel, TjvCSVComboBox, TjvCSVCheckBox, TjvCSVNavigator]);
  RegisterPropertyEditor(TypeInfo(string), TjvCSVBase, 'CSVFileName',  TCSVFileNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TjvCSVEdit, 'CSVField',  TCSVFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TjvCSVLabel, 'CSVField',  TCSVFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TjvCSVComboBox, 'CSVField',  TCSVFieldProperty);
  RegisterPropertyEditor(TypeInfo(string), TjvCSVCheckBox, 'CSVField',  TCSVFieldProperty);
end;

{ TjvCSVBase }

constructor TjvCSVBase.Create(AOwner: TComponent);
begin
 inherited;
 DB:=tstringlist.create;
 DBRecord:=tstringlist.create;
 DBFields:=tstringlist.create;
 FCSVFieldNames:=TStringList.create;
 DBCursor:=-1;
 DBOpen:=false;
end;

procedure TjvCSVBase.DataBaseClose;
begin
  FCSVFileName:='';
  DBCursor:=-1;
  DoCursorChange;
end;


procedure TjvCSVBase.DataBaseCreate(aFile: string; FieldNames: TStringList);
var newfile:string;
    Alist:tstringlist;
begin
  newfile:=changefileext(aFile,'.csv') ;
  if fileexists(newfile) then
   if messagedlg('Replace existing database?',mtconfirmation,[mbyes,mbno],0)=mrno then exit;
  alist:=tstringlist.create;
  if (FieldNames<>nil) then
   if FieldNames.count>0 then
    alist.Text:=FieldNames.CommaText ;
  alist.SaveToFile(newfile);
end;

procedure TjvCSVBase.DataBaseOpen(AFile: string);
begin
  if not fileexists(Afile) then
    DataBaseCreate(Afile,nil);
  FCSVFileName:=AFile;
  DB.LoadFromFile (CSVFileName);
  DBCursor:=-1;
  DBFields.Clear ;
  DBRecord.Clear ;
  if DB.Count >0 then begin
   DBCursor:=0;
   DBFields.CommaText :=DB[0];
   FCSVFieldNames.commatext:=DB[0];
   if DB.count>1 then begin
    DBCursor:=1;
    DBRecord.commatext:=DB[DBCursor];
    DoCursorChange;
    end;
   end;
end;

procedure TjvCSVBase.DataBaseRestructure(aFile:string; Fieldnames: TstringList);
var OldBase:tstringlist;
    OldRec:Tstringlist;
    OldFields:TStringlist;
    NewBase:tstringlist;
    NewRec:TStringlist;
    NewFields:TStringlist;
    index,rec,fld:integer;
begin
 DataBaseClose;
 if Fieldnames.count=0 then begin
  showmessage('no fields defined');
  exit;
  end;
 OldBase:=tstringlist.create;
 OldRec:=Tstringlist.create;
 OldFields:=TStringlist.create;
 NewBase:=tstringlist.create;
 NewRec:=TStringlist.create;
 NewFields:=TStringlist.create;
 OldBase.LoadFromFile (afile);
 if OldBase.count=0 then begin
  NewFields.assign(FieldNames);
  NewBase.Append (NewFields.commatext);
  end
  else begin
 //restructure
 OldFields.CommaText :=Oldbase[0];
 NewFields.assign(FieldNames);
 NewBase.Append (NewFields.commatext);
 if OldBase.count>1 then
 for rec:=1 to OldBase.count-1 do begin
  OldRec.CommaText :=OldBase[rec];
  Newrec.Clear ;
  for fld:=0 to NewFields.count-1 do begin
   index:=OldFields.IndexOf (NewFields[fld]);
   if index=-1 then
    NewRec.Append ('-')
    else
    NewRec.Append (OldRec[index]);
   end;
  NewBase.Append (NewRec.commatext);
  end;
 end;
 NewBase.SaveToFile(afile);
 OldBase.free;
 OldRec.free;
 OldFields.free;
 NewBase.free;
 NewRec.free;
 NewFields.free;
end;

destructor TjvCSVBase.Destroy;
begin
 DB.Free;
 DBRecord.free;
 DBFields.Free;
 FCSVFieldNames.Free ;
 inherited;
end;

procedure TjvCSVBase.RecordNew;
var i:integer;
begin
 if DBCursor<>-1 then begin
  DBRecord.Clear ;
  for i:=0 to DBFields.Count -1 do
   DBRecord.Append ('-');
  DB.Append (DBRecord.commatext);
  DBCursor:=DB.count-1;
  DB.SaveToFile (CSVFileName);
  DoCursorChange;
  end;
end;

procedure TjvCSVBase.RecordDelete;
begin
  if DBCursor>0 then begin
  DB.Delete (DBCursor);
  if DBCursor>(DB.count-1) then dec(DBCursor);
  if DBCursor>0 then begin
   DBRecord.commatext:=DB[DBCursor];
   DB.SaveToFile (CSVFileName);
   end;
  DoCursorChange;
  end;
end;

function TjvCSVBase.RecordFind(Atext: string): boolean;
var i,from:integer;
    fs:string;
begin
 result:=false;
 if DBCursor<1 then exit;
  if DBCursor<(DB.Count -1) then begin
   from:=DBCursor+1;
   fs:=lowercase(AText);
   for i:=from to DB.Count -1 do
    if pos(fs,lowercase(DB[i]))>0 then begin
     DBCursor:=i;
     DBRecord.commatext:=DB[DBCursor];
     result:=true;
     DoCursorChange;
     break;
     end;
   end;
end;

function TjvCSVBase.RecordFirst: boolean;
begin
  result:=false;
  if DBCursor<>-1 then
   if DB.count>1 then begin
   DBCursor:=1;
   DBRecord.commatext:=DB[DBCursor];
   result:=true;
   DoCursorChange;   
  end;
end;

procedure TjvCSVBase.RecordGet(var NameValues: TstringList);
var i:integer;
begin
 NameValues.clear;
 if DBCursor<1 then exit;
 for i:=0 to DBFields.Count -1 do
  NameValues.Append (DBFields[i]+'='+DBRecord[i]);
end;

function TjvCSVBase.RecordLast: boolean;
begin
 result:=false;
 if DBCursor<>-1 then
  if DB.count>1 then  begin
   DBCursor:=DB.count-1;
   DBRecord.commatext:=DB[DBCursor];
   result:=true;
   DoCursorChange;
  end;
end;

function TjvCSVBase.RecordNext: boolean;
begin
 result:=false;
 if DBCursor<>-1 then begin
  if DBCursor<(DB.Count -1) then begin
   inc(DBCursor);
   DBRecord.commatext:=DB[DBCursor];
   result:=true;
   DoCursorChange;
   end;
  end;

end;

function TjvCSVBase.RecordPrevious: boolean;
begin
 result:=false;
 if DBCursor<>-1 then begin
  if DBCursor>1 then begin
   dec(DBCursor);
   DBRecord.commatext:=DB[DBCursor];
   result:=true;
   DoCursorChange;
   end;
  end;


end;

procedure TjvCSVBase.RecordSet(NameValues:TStringList);
var i,index:integer;
    FieldName:string;
begin
  if NameValues.count>0 then begin
   for i:=0 to NameValues.count-1 do begin
    FieldName:=NameValues.names[i];
    index:=DBFields.IndexOf (FieldName);
    if index<>-1 then
     DBRecord[index]:=NameValues.Values [FieldName];
    end;
   DB[DBCursor]:=DBRecord.CommaText ;
   DB.SaveToFile (CSVFileName);
   end;
end;

procedure TjvCSVBase.SetonCursorChanged(const Value: TonCursorChanged);
begin
  FonCursorChanged := Value;
end;

procedure TjvCSVBase.CursorChanged(NameValues: TStringList;FieldCount:integer);
begin
 if assigned(onCursorchanged) then
  onCursorChanged(self,NameValues,FieldCount);
end;

procedure TjvCSVBase.DoCursorChange;
var NameValues:TStringlist;
begin
 NameValues:=TStringList.create;
 try
  RecordGet(NameValues);
  DisPlayFields(NameValues);
  CursorChanged(NameValues,NameValues.count);
  finally
  NameValues.Free ;
  end;
end;

procedure TjvCSVBase.DisPlayFields(NameValues:TStringlist);
var Aform:TForm;
    i,index:integer;
    ed:TjvCSVEdit;
    lb:TjvCSVLabel;
    cbo:TjvCSVComboBox;
    ck:TjvCSVCheckBox;
    AField:string;
begin
 Aform:=TForm(self.Owner );
 for i:=0 to aForm.ComponentCount-1 do
  if aform.Components [i].classname='TjvCSVEdit' then begin
   ed:=TjvCSVEdit(aform.Components[i]);
   if ed.CSVDataBase =self then begin
     Afield:=ed.CSVField ;
     index:= CSVFieldNames.IndexOf (AField);
     if index<>-1 then
      if DBCursor>0 then
       ed.Text :=DBRecord[index]
       else
       ed.Text:='['+Afield+']';
     end;
   end
   else if aform.Components [i].classname='TjvCSVLabel' then begin
   lb:=TjvCSVLabel(aform.Components[i]);
   if lb.CSVDataBase =self then begin
     Afield:=lb.CSVField ;
     index:= CSVFieldNames.IndexOf (AField);
     if index<>-1 then
      if DBCursor>0 then
       lb.Caption :=DBRecord[index]
       else
       lb.Caption:='['+Afield+']';
     end;
   end
  else if aform.Components [i].classname='TjvCSVComboBox' then begin
   cbo:=TjvCSVComboBox(aform.Components[i]);
   if cbo.CSVDataBase =self then begin
     Afield:=cbo.CSVField ;
     index:= CSVFieldNames.IndexOf (AField);
     if index<>-1 then
      if DBCursor>0 then
       cbo.Text :=DBRecord[index]
       else
       cbo.Text:='['+Afield+']';
     end;
   end
  else if aform.Components [i].classname='TjvCSVCheckBox' then begin
   ck:=TjvCSVCheckBox(aform.Components[i]);
   if ck.CSVDataBase =self then begin
     Afield:=ck.CSVField ;
     index:= CSVFieldNames.IndexOf (AField);
     if index<>-1 then
      if DBCursor>0 then
       ck.checked :=DBRecord[index]='true'
       else
       ck.Checked :=false;
     end;
   end;
end;


procedure TjvCSVBase.SetCSVFileName(const Value: string);
begin
  if value<>FCSVFileName then begin
   DatabaseClose;
   FCSVFileName := Value;
   if fileexists(CSVFileName) then
     DataBaseOpen(CSVFileName)
     else
     DataBaseCreate(CSVFileName,nil);
   end;
end;

procedure TjvCSVBase.DisPlay;
begin
 doCursorChange;
end;

procedure TjvCSVBase.RecordPost;
var Aform:TForm;
    i,index:integer;
    ed:TjvCSVEdit;
    lb:TjvCSVLabel;
    cbo:TjvCSVComboBox;
    ck:TjvCSVCheckBox;
    AField:string;
begin
 if DBCursor<1 then exit;
 Aform:=TForm(self.Owner );
 for i:=0 to aForm.ComponentCount-1 do
  if aform.Components [i].classname='TjvCSVEdit' then begin
   ed:=TjvCSVEdit(aform.Components[i]);
   if ed.CSVDataBase =self then begin
     Afield:=ed.CSVField ;
     index:= CSVFieldNames.IndexOf (AField);
     if index<>-1 then
      DBRecord[index]:=ed.text;
     end;
   end
   else if aform.Components [i].classname='TjvCSVLabel' then begin
   lb:=TjvCSVLabel(aform.Components[i]);
   if lb.CSVDataBase =self then begin
     Afield:=lb.CSVField ;
     index:= CSVFieldNames.IndexOf (AField);
     if index<>-1 then
      DBRecord[index]:=lb.Caption;
     end;
   end
  else if aform.Components [i].classname='TjvCSVComboBox' then begin
   cbo:=TjvCSVComboBox(aform.Components[i]);
   if cbo.CSVDataBase =self then begin
     Afield:=cbo.CSVField ;
     index:= CSVFieldNames.IndexOf (AField);
     if index<>-1 then
      DBRecord[index]:=cbo.text;
     end;
   end
  else if aform.Components [i].classname='TjvCSVCheckBox' then begin
   ck:=TjvCSVCheckBox(aform.Components[i]);
   if ck.CSVDataBase =self then begin
     Afield:=ck.CSVField ;
     index:= CSVFieldNames.IndexOf (AField);
     if index<>-1 then
      if ck.Checked then
       DBRecord[index]:='true'
       else
       DBRecord[index]:='false';
     end;
   end;


 DB[DBCursor]:=DBRecord.CommaText ;
 DB.SaveToFile (CSVFileName);
end;


{ TCSVFileNameProperty }


procedure TjvCSVBase.SetCSVFieldNames(const Value: TStringlist);
var oldfile:string;
begin
  if (CSVFileName<>'') and (value.Count >0) then begin
   OldFile:=CSVFileName;
   DataBaseClose;
   FCSVFieldNames.Assign(Value);
   DataBaseRestructure(oldFile,value);
   DataBaseOpen(OldFile);
   end;
end;

{ TCSVFileNameProperty }

procedure TCSVFileNameProperty.Edit;
var dlg:TOpenDialog;
begin
 dlg:=TOpendialog.Create (application);
 dlg.FileName :=getValue;
 if dlg.Execute then
    SetValue(dlg.filename);
 dlg.free;
end;

function TCSVFileNameProperty.GetAttributes: TPropertyattributes;
begin
 result:=[padialog];
end;


{ TjvCSVEdit }

procedure TjvCSVEdit.Notification(Acomponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation=opRemove) and (AComponent=FCSVDataBase) then begin
    FCSVDataBase:= nil;
    FCSVField:='';
    end;
end;

procedure TjvCSVLabel.Notification(Acomponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation=opRemove) and (AComponent=FCSVDataBase) then begin
    FCSVDataBase:= nil;
    FCSVField:='';
    end;
end;

procedure TjvCSVLabel.SetCSVDataBase(const Value: TjvCSVBase);
begin
  FCSVDataBase := Value;
end;

procedure TjvCSVEdit.SetCSVDataBase(const Value: TjvCSVBase);
begin
  FCSVDataBase := Value;
end;

procedure TjvCSVEdit.SetCSVField(const Value: string);
begin
  if value<>FCSVField then begin
   FCSVField := Value;
   if assigned(FCSVDataBase) then
    CSVDataBase.display;
   end;
end;

procedure TjvCSVLabel.SetCSVField(const Value: string);
begin
  if value<>FCSVField then begin
   FCSVField := Value;
   if assigned(FCSVDataBase) then
    CSVDataBase.display;
   end;
end;
{ TCSVFieldProperty }

function TCSVFieldProperty.GetAttributes: TPropertyAttributes;
begin
 result:=[paValueList];
end;

procedure TCSVFieldProperty.GetValues(Proc: TGetStrProc);
var i,c:integer;
    dbedit:TjvCSVEdit;
    dbLabel: TjvCSVLabel;
    dbcombo:TjvCSVComboBox;
    ck:TjvCSVCheckBox;
    AComponent:TPersistent;
begin
 try
   Acomponent:=getcomponent(0);
   if Acomponent.ClassName ='TjvCSVEdit' then begin
     dbedit:=TjvCSVEdit(getcomponent(0));
     if assigned(dbedit.CSVDataBase) then begin
      c:= dbEdit.CSVDataBase.CSVFieldNames.count;
      if c>0 then
      for i:=0 to c-1 do Proc(dbEdit.CSVDataBase.CSVFieldNames[i]);
      end;
     end
    else if Acomponent.ClassName ='TjvCSVLabel' then begin
     dbLabel:=TjvCSVLabel(getcomponent(0));
     if assigned(dbLabel.CSVDataBase) then begin
      c:= dbLabel.CSVDataBase.CSVFieldNames.count;
      if c>0 then
      for i:=0 to c-1 do Proc(dbLabel.CSVDataBase.CSVFieldNames[i]);
      end;
     end
   else if Acomponent.ClassName='TjvCSVComboBox' then begin
     dbcombo:=TjvCSVComboBox(getcomponent(0));
     if assigned(dbcombo.CSVDataBase) then begin
      c:= dbcombo.CSVDataBase.CSVFieldNames.count;
      if c>0 then
      for i:=0 to c-1 do Proc(dbcombo.CSVDataBase.CSVFieldNames[i]);
      end;
     end
   else if Acomponent.ClassName='TjvCSVCheckBox' then begin
     ck:=TjvCSVCheckBox(getcomponent(0));
     if assigned(ck.CSVDataBase) then begin
      c:= ck.CSVDataBase.CSVFieldNames.count;
      if c>0 then
      for i:=0 to c-1 do Proc(ck.CSVDataBase.CSVFieldNames[i]);
      end;
     end;
  except
  end;
end;

{ TjvCSVNavigator }

procedure TjvCSVNavigator.btnAddClick(sender: TObject);
begin
 if assigned(FCSVDataBase) then
  CSVDataBase.RecordNew;

end;

procedure TjvCSVNavigator.btnDeleteClick(sender: TObject);
begin
 if assigned(FCSVDataBase) then
  CSVDataBase.RecordDelete;

end;

procedure TjvCSVNavigator.btnFindClick(sender: TObject);
var Atext:string;
begin
 if assigned(FCSVDataBase) then begin
    Atext:=inputbox('CSV DataBase','Find Text:','');
    if Atext<>'' then
     CSVDataBase.RecordFind(Atext);
    end;

end;

procedure TjvCSVNavigator.btnFirstClick(sender: TObject);
begin
 if assigned(FCSVDataBase) then
  CSVDataBase.RecordFirst;
end;

procedure TjvCSVNavigator.btnLastClick(sender: TObject);
begin
 if assigned(FCSVDataBase) then
  CSVDataBase.RecordLast;

end;

procedure TjvCSVNavigator.btnNextClick(sender: TObject);
begin
 if assigned(FCSVDataBase) then
  CSVDataBase.RecordNext;

end;

procedure TjvCSVNavigator.btnPostClick(sender: TObject);
begin
 if assigned(FCSVDataBase) then
  CSVDataBase.RecordPost;
end;

procedure TjvCSVNavigator.btnPreviousClick(sender: TObject);
begin
 if assigned(FCSVDataBase) then
  CSVDataBase.RecordPrevious;

end;

procedure TjvCSVNavigator.btnRefreshClick(sender: TObject);
begin
 if assigned(FCSVDataBase) then
  CSVDataBase.display;

end;

constructor TjvCSVNavigator.create(AOwner: Tcomponent);

begin
  inherited;
  height:=24;
  width:=217;
  CreateButtons;
  Caption:='';
end;

procedure TjvCSVNavigator.CreateButtons;
  procedure ib(b:TSpeedButton);
  begin
   b.Width :=23;
   b.height:=22;
   b.flat:=false;
   b.parent:=self;
   b.top:=1;
   showhint:=true;
  end;

begin
  FbtnFirst := TSpeedButton.Create(Self);
  with FbtnFirst do begin
   ib(FbtnFirst);
   Glyph.LoadFromLazarusResource('FIRST');
   Left := 1;
   OnClick := BtnFirstClick;
   hint:='First';
   end;

  FbtnPrevious := TSpeedButton.Create(Self);
  with FbtnPrevious do begin
   ib(FbtnPrevious);
   Glyph.LoadFromLazarusResource('PREVIOUS');
   Left := 25;
   OnClick := BtnPreviousClick;
   hint:='Previous';
   end;

  FbtnFind := TSpeedButton.Create(Self);
  with FbtnFind do begin
   ib(FbtnFind);
   Glyph.LoadFromLazarusResource('FIND');
   Left := 49;
   OnClick := BtnFindClick;
   hint:='Find';
   end;

  FbtnNext := TSpeedButton.Create(Self);
  with FbtnNext do begin
   ib(FbtnNext);
   Glyph.LoadFromLazarusResource('NEXT');
   Left := 73;
   OnClick := BtnNextClick;
   hint:='Next';
   end;

  FbtnLast := TSpeedButton.Create(Self);
  with FbtnLast do begin
   ib(FbtnLast);
   Glyph.LoadFromLazarusResource('LAST');
   Left := 97;
   OnClick := BtnLastClick;
   hint:='Last';
   end;

  FbtnAdd := TSpeedButton.Create(Self);
  with FbtnAdd do begin
   ib(FbtnAdd);
   Glyph.LoadFromLazarusResource('ADD');
   Left := 121;
   OnClick := BtnAddClick;
   hint:='Add';
   end;

  FbtnDelete := TSpeedButton.Create(Self);
  with FbtnDelete do begin
   ib(FbtnDelete);
   Glyph.LoadFromLazarusResource('DELETE');
   Left := 145;
   OnClick := BtnDeleteClick;
   hint:='Delete';
   end;

  FbtnPost := TSpeedButton.Create(Self);
  with FbtnPost do begin
   ib(FbtnPost);
   Glyph.LoadFromLazarusResource('POST');
   Left := 169;
   OnClick := BtnPostClick;
   hint:='Post';
   end;

  FbtnRefresh := TSpeedButton.Create(Self);
  with FbtnRefresh do begin
   ib(FbtnRefresh);
   Glyph.LoadFromLazarusResource('REFRESH');
   Left := 193;
   OnClick := BtnRefreshClick;
   hint:='Refresh';
   end;

end;

procedure TjvCSVNavigator.CreateWnd;
begin
  inherited;
  caption:='';
end;

destructor TjvCSVNavigator.destroy;
begin
  inherited;

end;

procedure TjvCSVNavigator.Notification(Acomponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation=opRemove) and (AComponent=FCSVDataBase) then begin
    FCSVDataBase:= nil;
    end;


end;

procedure TjvCSVNavigator.Resize;
begin
  inherited;
  height:=24;
  if width<221 then width:=221;
  if assigned(onresize) then onresize(self);
end;


procedure TjvCSVNavigator.SetCSVDataBase(const Value: TjvCSVBase);
begin
  FCSVDataBase := Value;
end;

{ TjvCSVComboBox }

procedure TjvCSVComboBox.Notification(Acomponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation=opRemove) and (AComponent=FCSVDataBase) then begin
    FCSVDataBase:= nil;
    FCSVField:='';
    end;
end;

procedure TjvCSVComboBox.SetCSVDataBase(const Value: TjvCSVBase);
begin
  FCSVDataBase := Value;
end;

procedure TjvCSVComboBox.SetCSVField(const Value: string);
begin
  if value<>FCSVField then begin
   FCSVField := Value;
   if assigned(FCSVDataBase) then
    CSVDataBase.display;
   end;
end;

{ TjvCSVCheckBox }

procedure TjvCSVCheckBox.Notification(Acomponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation=opRemove) and (AComponent=FCSVDataBase) then begin
    FCSVDataBase:= nil;
    FCSVField:='';
    end;
end;

procedure TjvCSVCheckBox.SetCSVDataBase(const Value: TjvCSVBase);
begin
  FCSVDataBase := Value;
end;

procedure TjvCSVCheckBox.SetCSVField(const Value: string);
begin
  if value<>FCSVField then begin
   FCSVField := Value;
   if assigned(FCSVDataBase) then
    CSVDataBase.display;
   end;
end;
initialization
  {$I jvCSVBase.lrs}
end.
