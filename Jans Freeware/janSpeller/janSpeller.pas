unit janSpeller;

{$MODE Delphi}

interface

uses
  Interfaces,
  LCLIntf,
  LCLType,
  LCLProc,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  LResources;

type
  TjanSpeller=class;

  { TjanSpellerF }

  TjanSpellerF = class(TForm)
    btnAdd: TButton;
    btncancel: TButton;
    btnchange: TButton;
    btnSkip: TButton;
    btnskipall: TButton;
    Label1: TLabel;
    Label2: TLabel;
    lblContext: TMemo;
    txtspell: TEdit;
  private
    { Private declarations }
    FSpeller:TjanSpeller;
  public
    { Public declarations }
  end;

  TjanSpeller = class(TComponent)
  private
   { Private declarations }
    FSourceText:string;
    Dictionary:string;
    UserDic:string;
    UserDicFile:string;
    UserDicChanged:boolean;
    DicIndex:array[1..26] of integer;
    UserDicIndex:array[1..26] of integer;
    SpellerDlg: TjanSpellerF;
    FWordBegin:integer;
    FWordEnd:integer;
    function WordBegin:boolean;
    function WordEnd:boolean;
    function ParseWord:string;
    procedure SpellNext;
    procedure Skip(Sender:TObject);
    procedure Add(Sender:TObject);
    procedure Change(sender:Tobject);
    procedure IndexDictionary;
    procedure IndexUserDictionary;
  protected
    { Protected declarations }
  public
    { Public declarations }
    constructor Create(AOwner:TComponent); override;
    procedure LoadDictionary(aFile:string);
    procedure LoadUserDictionary(aFile:string);
    procedure Spell( var SourceText:string);
  published
    { Published declarations }
  end;

procedure Register;


var
  janSpellerF: TjanSpellerF;

implementation



const
  cr = chr(13)+chr(10);
  tab = chr(9);

procedure Register;
begin
  RegisterComponents('janBasic', [TjanSpeller]);
end;


function Q_PosStr(const FindString, SourceString: string; StartPos: Integer): Integer;
asm
        PUSH    ESI
        PUSH    EDI
        PUSH    EBX
        PUSH    EDX
        TEST    EAX,EAX
        JE      @@qt
        TEST    EDX,EDX
        JE      @@qt0
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EAX,[EAX-4]
        MOV     EDX,[EDX-4]
        DEC     EAX
        SUB     EDX,EAX
        DEC     ECX
        SUB     EDX,ECX
        JNG     @@qt0
        MOV     EBX,EAX
        XCHG    EAX,EDX
        NOP
        ADD     EDI,ECX
        MOV     ECX,EAX
        MOV     AL,BYTE PTR [ESI]
@@lp1:  CMP     AL,BYTE PTR [EDI]
        JE      @@uu
@@fr:   INC     EDI
        DEC     ECX
        JNZ     @@lp1
@@qt0:  XOR     EAX,EAX
        JMP     @@qt
@@ms:   MOV     AL,BYTE PTR [ESI]
        MOV     EBX,EDX
        JMP     @@fr
@@uu:   TEST    EDX,EDX
        JE      @@fd
@@lp2:  MOV     AL,BYTE PTR [ESI+EBX]
        XOR     AL,BYTE PTR [EDI+EBX]
        JNE     @@ms
        DEC     EBX
        JNE     @@lp2
@@fd:   LEA     EAX,[EDI+1]
        SUB     EAX,[ESP]
@@qt:   POP     ECX
        POP     EBX
        POP     EDI
        POP     ESI
end;


procedure SaveString(aFile, aText:string);
begin
  with TFileStream.Create(aFile, fmCreate) do try
    writeBuffer(aText[1],length(aText));
    finally free; end;
end;

function  LoadString(aFile:string):string;
var s:string;
begin
  with TFileStream.Create(aFile, fmOpenRead) do try
    SetLength(s, Size);
      ReadBuffer(s[1], Size);
    finally free; end;
  result:=s;
end;


{ TjanSpeller }


procedure TjanSpeller.Add(Sender: TObject);
var s:string;
    list:Tstringlist;
begin
  s:=SpellerDlg.txtspell.text;
  if s='' then exit;
  UserDic:=UserDic+lowercase(s)+cr;
  UserDicChanged:=true;
  list:=TStringlist.create;
  list.text:=UserDic;
  list.Sort;
  UserDic:=list.text;
  list.free;
  IndexUserDictionary;
  skip(sender);
end;

procedure TjanSpeller.Change(sender: Tobject);
var L:integer;
    s:string;
begin
  s:=SpellerDlg.txtspell.text;
  if s='' then exit;
  L:=length(s);
  FSourceText:=copy(FSourceText,1,FWordBegin-1)+s+ copy(FSourceText,FWordEnd,length(FsourceText));
  FWordEnd:=FWordEnd+ (L-(FWordEnd-FWordBegin));
  Skip(sender);
end;




constructor TjanSpeller.Create(AOwner: TComponent);
var i:integer;
begin
  inherited;
  for i:=1 to 26 do
  begin
    DicIndex[i]:=1;
    UserDicIndex[i]:=1;
  end;
end;

procedure TjanSpeller.IndexDictionary;
var i,p,startpos:integer;
begin
  DicIndex[1]:=1;
  for i:=2 to 26 do
  begin
    if DicIndex[i-1]<>1 then
      Startpos:=DicIndex[i-1] else StartPos:=1;
    p:=Q_PosStr(cr+chr(96+i),Dictionary,startpos);
    if p<>0 then DicIndex[i]:=p else DicIndex[i]:=DicIndex[i-1];
  end;
end;

procedure TjanSpeller.IndexUserDictionary;
var i,p,startpos:integer;
begin
  UserDicIndex[1]:=1;
  for i:=2 to 26 do
  begin
    if UserDicIndex[i-1]<>1 then
      Startpos:=UserDicIndex[i-1] else StartPos:=1;
    p:=Q_PosStr(cr+chr(96+i),UserDic,startpos);
    if p<>0 then UserDicIndex[i]:=p else UserDicIndex[i]:=UserDicIndex[i-1];
  end;
end;


procedure TjanSpeller.LoadDictionary(aFile: string);
begin
  if fileexists(aFile) then
    Dictionary:=LoadString(aFile);
  IndexDictionary;
end;

procedure TjanSpeller.LoadUserDictionary(aFile: string);
begin
  UserDicFile:=aFile;
  UserDicChanged:=false;
  if fileexists(aFile) then
    UserDic:=LoadString(afile);
  IndexUserDictionary;
end;

function TjanSpeller.ParseWord: string;
var p:integer;
begin
  result:='';
  if not WordBegin then exit;
  if not WordEnd then exit;
  result:=copy(FSourceText,FWordBegin,FWordEnd-FWordBegin);
end;




procedure TjanSpeller.Skip(Sender: TObject);
begin
  SpellerDlg.txtspell.text:='';
  SpellNext;
end;

procedure TjanSpeller.Spell(var SourceText:string);
var spw,s:string;
    startpos,index:integer;
begin
  FSourceText:=SourceText;
  if Dictionary='' then
  begin
    showmessage('no dictionary loaded');
    exit;
  end;
  FWordEnd:=1;
  repeat
  spw:=ParseWord;
  s:=lowercase(spw);
  if spw<>'' then
  begin
    index:=ord(s[1])-96;
    if (index>0) and (index<27) then
      StartPos:=DicIndex[index]
    else
      StartPos:=1;
    if Q_PosStr(s+cr,Dictionary,StartPos)=0 then
      if UserDic<>'' then
      begin
        if (index>0) and (index<27) then
          StartPos:=UserDicIndex[index]
        else
          StartPos:=1;
        if Q_PosStr(s+cr,UserDic,StartPos)=0 then
        begin
          SpellerDlg:= TjanSpellerF.Create (application);
          SpellerDlg.FSpeller:=self;
          SpellerDlg.btnSkip.OnClick:=Skip;
          SpellerDlg.btnchange.OnClick:=Change;
          SpellerDlg.btnAdd.OnClick:=Add;
          SpellerDlg.btnAdd.Visible:=(UserDicFile<>'');
          SpellerDlg.txtspell.text:=spw;
          SpellerDlg.lblcontext.caption:=Copy(FSourceText,FWordbegin,75);

          try
            if SpellerDlg.showmodal= mrOk then
            begin
              SourceText:=FSourceText;
              if UserDicChanged then
                if UserDic<>'' then
                  SaveString(UserDicFile,UserDic);
            end;
          finally
            SpellerDlg.free;
          end;
          exit;
        end
      end
      else begin
        SpellerDlg:= TjanSpellerF.Create (application);
        SpellerDlg.FSpeller:=self;
        SpellerDlg.btnSkip.OnClick:=Skip;
        SpellerDlg.btnchange.OnClick:=Change;
        SpellerDlg.btnAdd.OnClick:=Add;
        SpellerDlg.btnAdd.Visible:=(UserDicFile<>'');
        SpellerDlg.txtspell.text:=spw;
        SpellerDlg.lblcontext.caption:=Copy(FSourceText,FWordbegin,75);
        try
          if SpellerDlg.showmodal= mrOk then
          begin
            SourceText:=FSourceText;
            if UserDicChanged then
              if UserDic<>'' then
                SaveString(UserDicFile,UserDic);
          end;
        finally
          SpellerDlg.free;
        end;
        exit;
     end;
  end;
  until spw='';
end;

procedure TjanSpeller.SpellNext;
var spw,s:string;
    index,StartPos:integer;
begin
  repeat
  spw:=ParseWord;
  s:=lowercase(spw);
  if spw<>'' then
  begin
    index:=ord(s[1])-96;
    if (index>0) and (index<27) then
      StartPos:=DicIndex[index]
    else
      StartPos:=1;
    if Q_PosStr(s+cr,Dictionary,StartPos)=0 then
      if UserDic<>'' then
      begin
        if (index>0) and (index<27) then
          StartPos:=UserDicIndex[index]
        else
          StartPos:=1;
        if Q_PosStr(s+cr,UserDic,StartPos)=0 then
        begin
          SpellerDlg.txtspell.text:=spw;
          SpellerDlg.lblcontext.caption:=Copy(FSourceText,FWordbegin,75);
          exit;
        end;
      end
      else begin
        SpellerDlg.txtspell.text:=spw;
        SpellerDlg.lblcontext.caption:=Copy(FSourceText,FWordbegin,75);
        exit;
      end;
  end;
  until spw='';
  SpellerDlg.ModalResult:=mrOK;
end;

function TjanSpeller.WordBegin: boolean;
var L:integer;
begin
  L:=length(FSourceText);
  FWordBegin:=FWordEnd;
  while (FWordBegin<=L) and (not (FSourceText[FWordBegin] in ['a'..'z','A'..'Z'])) do inc(FWordBegin);
  if FWordbegin<=L then result:=true else result:=false;
end;

function TjanSpeller.WordEnd: boolean;
var L:integer;
begin
  FWordEnd:=FWordBegin;
  L:=length(FSourceText);
  while (FWordEnd<=L) and (FSourceText[FWordEnd] in ['a'..'z','A'..'Z']) do inc(FWordEnd);
  if FWordEnd<=L then result:=true else result:=false;
end;



initialization
  {$i janSpeller.lrs}

end.