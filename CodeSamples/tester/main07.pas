unit Main9;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, K6Line1, K6Line2, K6Line3, K6Line4, K6Line5, K6Line6,
  K6Setup, ExtCtrls, StdCtrls;

type
  TMain = class(TForm)
    Menu: TMainMenu;
    Menu1: TMenuItem;
    Exit1: TMenuItem;
    Setup1: TMenuItem;
    Line11: TMenuItem;
    Line21: TMenuItem;
    Line31: TMenuItem;
    Line41: TMenuItem;
    Line51: TMenuItem;
    Line61: TMenuItem;
    AllTesters1: TMenuItem;
    Port1: TMenuItem;
    Com11: TMenuItem;
    Com21: TMenuItem;
    Com31: TMenuItem;
    Timer1: TTimer;
    SaveSettings1: TMenuItem;
    Timer2: TMenuItem;
    N25001: TMenuItem;
    N50001: TMenuItem;
    N75001: TMenuItem;
    N1Sec1: TMenuItem;
    N5001: TMenuItem;
    N2501: TMenuItem;
    Edit4: TEdit;
    Delay: TButton;
    EDIT99: TEdit;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button1: TButton;
    procedure Exit1Click(Sender: TObject);
    procedure Line11Click(Sender: TObject);
    procedure Line21Click(Sender: TObject);
    procedure Line31Click(Sender: TObject);
    procedure Line41Click(Sender: TObject);
    procedure Line51Click(Sender: TObject);
    procedure Line61Click(Sender: TObject);
    procedure AllTesters1Click(Sender: TObject);
    function  GetStatus(Id: Byte): Byte;
    function  NoRXResponseDialogue(Id: Byte) : Boolean;
    function  NoTXResponseDialogue(Id: Byte) : Boolean;
    function  CheckSumDialogue(Id: Byte) : Boolean;
    function  NoTxDialogue(Id: Byte) : Boolean;
    function  NoResetDialogue(Id: Byte; FPGAnum: byte) : Boolean;
    function  NoProgramDialogue(Id: Byte; FPGAnum: byte) : Boolean;
    function  WriteByte(WritenByte: Byte) : byte;
    function  WaitAfterBroadCast(Cmd: Byte) : byte;
    function  WriteCommand(Id: Byte; Cmd: Byte) : Byte;
    function  WriteFPGAFile(Id: Byte; FPGANum: Byte) : Byte;
    function  WaitForTX(TimeOutValue: Integer): Byte;
    function  ReadFrame(FrameLength: Byte): Byte;
    function  ReadByte(Rin: pchar): Byte;
    procedure InitialiseTester(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    function  WriteToLatch(Id: Byte; Latch: Byte; DataByte: Byte) : Byte;
    function  WriteFromLatch(Id: Byte; Command: Byte; Latch: Byte) : Byte;
    function  GetRegisterResult(CommandRead : Byte) : Byte;
    procedure InterfChange(Sender: TObject);
    procedure CheckInsError(Sender: TObject);
    procedure CheckDtrChange(Sender: TObject);
    procedure TestPatternSet(Sender: TObject);
    procedure ExecCmd3Sync(Sender: TObject);
    procedure ExecCmd30Status(Sender: TObject);
    function  WriteErrorCount(Id: Byte) : Byte;
    procedure ReportErrors(Sender: TObject);
    procedure ElapsTime(Sender: TObject);
    procedure ComSetup(Sender: TObject);
    procedure Com11Click(Sender: TObject);
    procedure Com21Click(Sender: TObject);
    procedure Com31Click(Sender: TObject);
    procedure N2501Click(Sender: TObject);
    procedure N5001Click(Sender: TObject);
    procedure N25001Click(Sender: TObject);
    procedure N50001Click(Sender: TObject);
    procedure N75001Click(Sender: TObject);
    procedure N1Sec1Click(Sender: TObject);
    procedure UpdateSync1(Sender: TObject);
    procedure UpdateSync2(Sender: TObject);
    procedure UpdateSync3(Sender: TObject);
    procedure UpdateSync4(Sender: TObject);
    procedure UpdateSync5(Sender: TObject);
    procedure UpdateSync6(Sender: TObject);
    procedure UpdateTest1(Sender: TObject);
    procedure UpdateTest2(Sender: TObject);
    procedure UpdateTest3(Sender: TObject);
    procedure UpdateTest4(Sender: TObject);
    procedure UpdateTest5(Sender: TObject);
    procedure UpdateTest6(Sender: TObject);
    procedure DelayClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);

private
   { Private declarations }
public
    { Public declarations }
  end;

var
  Main: TMain;
  time: TDateTime;
  UnitNo : byte;
  Error : Byte;

{Temp - settings}
  FPGALoopDelay:  Longint;
  ReadLoopDelay:  Integer;
  WriteLoopDelay: Integer;
  wAITdELAY: LONGINT;
  FrameLoop : Byte; {move this down to READFRAME procedure after testing}
{Communication Vars}
  CommStr: PChar;
  DCB:TDCB;
  Stat: TCOMSTAT;
  hComm: integer;

{Config File Vars}
  ReadBufferSize: word;
  WriteBufferSize: word;
  Buff1: array [1..3855] of byte;
  Buff2: array [1..3855] of byte;

{Loop & Control Vars}
  LoopTime: longint;
  WaitTime: longint;
  MainLoop: Byte;
  LoopCount: integer;
  TestId: Byte;

{Time Handling Vars}
  shi: shortint;
  smi: shortint;
  ssi: shortint;
  nhi: shortint;
  nmi: shortint;
  nsi: shortint;
  hh : string[2];
  mm : string[2];
  ss : string[2];
  nowtime: string[8];

{Read / Write Vars}
  buf : pchar;
  ReadByte : byte;
  WritenByte : byte;
  ReadBuf : array[1..5] of byte;
  StatusInd : array [0..7] of boolean;

{Miscellaneous Vars}
  NoActTest : Byte;
  Response: Boolean;
  FailCnt: smallint;
  SyncLoss: Boolean;
  InitFPGA: SmallInt;
  WaitNoResponse: Boolean;
  BinMask: array [0..7] of byte;

{Comm String Setup variables }
  Addr:        byte;
  Command:     byte;
  Latch:       byte;
  DataByte:    byte;
  CheckSum:    byte;
  ErrorCount1: byte;
  ErrorCount2: byte;

{ Line Setup and Parameters }
  ActiveTester:     array [1..6] of boolean;
  InterfaceType :   array [1..6] of byte;
  InterFaceChange : array [1..6] of boolean;
  TestPattern :     array [1..6] of byte;
  TestPatChange :   array [1..6] of boolean;
  TimeStart:        array [1..6] of string[8];
  InsertError:      array [1..6] of boolean;
  DtrRtsSet:        array [1..6] of boolean;
  DtrRstSelected:   array [1..6] of string[3];
  ErrCount :        array [1..6] of integer;

const Ok:             Byte = 0;
      RxTimeout:      Byte = 1;
      CheckSumErr:    Byte = 2;
      NotTXing:       Byte = 3;
      StatusByte:     Byte = 3;
      RepError:       Byte = 5;
      CheckStatus :   Byte = 6;
      ResetFPGACmd:   Byte = 7;
      TxTimeout:      Byte = 8;
      ReadSize :      Byte = 1;


implementation
{$R *.DFM}

procedure TMain.Exit1Click(Sender: TObject);
var  Button: Integer;
begin
  Button := Application.MessageBox('Are you sure you want to close ALL'+
  ' Testers ?', 'Closing the Main Tester Handler ', mb_OKCancel +
    mb_DefButton1);
      if Button = IDOK then
         CloseComm(hComm);
         close;
         exit;
end;

procedure TMain.Line11Click(Sender: TObject);
begin
    TestId := 1;
    K6Line1.TesWin1.show;
    InitialiseTester(Sender);
end;

procedure TMain.Line21Click(Sender: TObject);
begin
    TestId := 2;
    K6Line2.TesWin2.show;
    InitialiseTester(Sender);
end;

procedure TMain.Line31Click(Sender: TObject);
begin
   TestId := 3;
   K6Line3.TesWin3.show;
   InitialiseTester(Sender);
end;

procedure TMain.Line41Click(Sender: TObject);
begin
   TestId := 4;
   K6Line4.TesWin4.show;
   InitialiseTester(Sender);
end;

procedure TMain.Line51Click(Sender: TObject);
begin
   TestId := 5;
   K6Line5.TesWin5.show;
   InitialiseTester(Sender);
end;

procedure TMain.Line61Click(Sender: TObject);
begin
   TestId := 6;
   K6Line6.TesWin6.show;
   InitialiseTester(Sender);
end;

procedure TMain.AllTesters1Click(Sender: TObject);
begin
   TestId := 0;
   K6Line1.TesWin1.show;
   K6Line2.TesWin2.show;
   K6Line3.TesWin3.show;
   K6Line4.TesWin4.show;
   K6Line5.TesWin5.show;
   K6Line6.TesWin6.show;
   InitialiseTester(Sender);
end;

function TMain.GetStatus(Id: Byte): Byte;
label GetStatusStart, GetStatusExit;
begin

GetStatus := Ok;

GetStatusStart:

   If WriteCommand(Id,CheckStatus) = TxTimeout then
     begin
       If NoTxDialogue(Id) = true then
         begin
           goto GetStatusStart ;
         end
       else
         begin
           GetStatus := TxTimeout;
         end;
     end
   else
     begin
       Error := ReadFrame(4);
       if Error = CheckSumErr then
         begin
           if CheckSumDialogue(Id) = false then
             begin
               GetStatus := CheckSumErr;
             end
           else
             begin
               goto GetStatusStart;
             end;
         end
       else
         if Error = RxTimeOut then
           begin
             if NoRXResponseDialogue(Id) = false then
                begin
                  GetStatus := RxTimeOut;
                end
             else
                begin
                  goto GetStatusStart;
                end;
           end
         else
           begin
             GetStatus := Ok;
           end;
     end;
 end;

Function TMain.NoTXResponseDialogue(Id: Byte) : Boolean;
begin
if MessageDlg('Tester ' + inttostr(Id) + ' is not responding to Transmit.  '+
              '    Try Again ?',
              mtInformation, [mbYes, mbNo], 0) = mrYes then
                begin
                    NoTXResponseDialogue := true;
                end
             else
                begin
                   NoTXResponseDialogue := false;
                end;
end;

Function TMain.NoRXResponseDialogue(Id: Byte) : Boolean;
begin
if MessageDlg('Tester ' + inttostr(Id) + ' is not responding to Receive. '+
              '    Try Again ?',
              mtInformation, [mbYes, mbNo], 0) = mrYes then
                begin
                    NoRXResponseDialogue := true;
                end
             else
                begin
                   NoRXResponseDialogue := false;
                end;
end;

Function TMain.CheckSumDialogue(Id: Byte) : Boolean;
begin
if MessageDlg('Tester ' + inttostr(Id) + ' returned a corrupt frame. Try Again ?',
              mtInformation, [mbYes, mbNo], 0) = mrYes then
                begin
                    CheckSumDialogue := true;
                end
              else
                begin
                   CheckSumDialogue := false;
                end;
end;

function TMain.NoTxDialogue(Id: Byte) : Boolean;
begin
if MessageDlg('Tester ' + inttostr(Id) + ' Output Queue is not empty. Try Again ?',
              mtInformation, [mbYes, mbNo], 0) = mrYes then
                begin
                  NoTxDialogue := true;
                end
              else
                begin
                  NoTxDialogue := false;
                end;
end;

function TMain.NoResetDialogue(Id: Byte; FPGAnum: byte) : Boolean;
begin
if MessageDlg('Tester ' + inttostr(Id) + 'FPGA ' + inttostr(FPGANum) +
              ' has not reset successfully. Try Again ?',
              mtInformation, [mbYes, mbNo], 0) = mrYes then
                begin
                    NoResetDialogue := true;
                end
              else
                begin
                   NoResetDialogue := false;
                end;
end;

function TMain.NoProgramDialogue(Id: Byte; FPGAnum: byte) : Boolean;
begin
if MessageDlg('Tester ' + inttostr(Id) + ' has not programmed successfully.'+
'    The value in status is :' +inttostr(ReadBuf[StatusByte]) +
' FPGA Number : '+ inttostr(FPGANum) + '    Try Again ?',
              mtInformation, [mbYes, mbNo], 0) = mrYes then
                begin
                    NoProgramDialogue := true;
                end
              else
                begin
                   NoProgramDialogue := false;
                end;
end;


function TMain.WriteByte(WritenByte: Byte) :byte;
var PCh : Pchar;
begin
    WriteByte := Ok;
    PCh:= @WritenByte;
    TransmitCommChar(hComm, PCh^);
end;

function TMain.WaitAfterBroadCast(Cmd: Byte) : byte;
var WABLoop : longint;
    WABCntr : longint;
begin
    WABCntr := 0;

For WABLoop := 1 to WaitDelay do
   begin
      WabCntr := WabCntr + 1;
   end;
end;

function TMain.WriteCommand(Id: Byte; Cmd: Byte) : Byte;
var TxResponse : Boolean;
begin

WriteCommand := Ok;
WritenByte := Id;
WriteByte(WritenByte);
WritenByte := Cmd;    {Command}
WriteByte(WritenByte);
CheckSum := id + Cmd ;
WritenByte := CheckSum;      {CheckSum}
WriteByte(WritenByte);
WriteCommand := WaitForTx(WriteLoopDelay);

end;

function TMain.WriteFPGAFile(Id: Byte; FPGANum: Byte) : Byte;
var TxResponse : Boolean;
begin

 WriteFPGAFile := Ok;
 WriteByte(Id);
 WriteByte(FPGANum);

 if FPGANum = 1 then
   begin
     WriteComm(hComm, @Buff1, 3854);
   end
 else
    begin
     WriteComm(hComm, @Buff2, 3854);
   end;

 WriteFPGAFile := WaitForTx(FPGALoopDelay);

 end;


function TMain.WaitForTX(TimeOutValue: Integer): Byte;
var ResultX : Integer;
    NormFpgaLoop : integer;
label StartLoopTx, EndProcTx;
begin
WaitForTx := Ok;
WaitNoResponse:= false;
LoopCount := 0;
StartLoopTx:

GetCommError(hComm,Stat);

if stat.cbOutQue = 0 then
  begin
    WaitForTx := Ok;
    goto EndProcTx;
  end;

If LoopCount > TimeOutValue then
  begin
   WaitForTx := TxTimeout;
   goto EndProcTx;
  end;

If TimeOutValue = FPGALoopDelay then
   begin
     NormFPGALoop := 600;
   end
else
   begin
     NormFPGALoop := 200;
   end;

for looptime := 1 to NormFPGALoop do
    begin
      waittime := waittime + 1;
    end;

LoopCount := LoopCount + 1;

goto StartLoopTx;

EndProcTx:

end;

function TMain.ReadFrame(FrameLength: Byte): Byte;
var  CheckSum: Byte;

begin
  ReadFrame := OK;
  FrameLoop := 0;
  CheckSum := 0;

for FrameLoop := 1 to FrameLength do
  begin
    Buf :=  @readbuf[FrameLoop];
    if ReadByte( Buf ) = RxTimeout then
      begin
        ReadFrame := RxTimeOut;
        Exit;
      end;
    end;

CheckSum := 0;
FrameLoop := 0;

for FrameLoop := 1 to (FrameLength - 1) do
  begin
    CheckSum := CheckSum + ReadBuf[FrameLoop];
  end;

if CheckSum <> ReadBuf[FrameLength] then
  begin
    ReadFrame := CheckSumErr;
    Exit;
  end;

ReadFrame := OK;
end;

function TMain.ReadByte(RIN: pchar): Byte;
var TryAgain: Boolean;
    ReadCount: Integer;
    ErrResult: Integer;
    TryCounter: word;
    LocalLoop: byte;

begin

  ReadByte := Ok;
  TryCounter := 0;
  TryAgain := true;

While TryAgain do
  begin
    ReadCount := ReadComm(hComm,RIN,1);
    if ReadCount = 0 then
      begin
        TryCounter := TryCounter + 1;
        if TryCounter > ReadLoopDelay then
           begin
             ReadByte := RXTimeOut;
             TryAgain := false;
             exit;
           end
        else
           begin
              for LocalLoop := 1 to 200 do
                begin
                  WaitTime := WaitTime + 1;
                end;
           end;
      end
    else
      begin
        if ReadCount < 0 then
          begin
            ErrResult := GetCommError(hComm,Stat);
            if ErrResult <> 0 then
               begin
                  ShowMessage('GetCommError Code : ' + inttostr(ErrResult));
                  exit;
               end;
          end
        else
          begin
            ReadByte := OK;
            TryAgain := false;
            exit;
          end;
      end;
  end;
end;


procedure TMain.InitialiseTester(Sender: TObject);
label Reset,FPGALOAD1,FPGALOAD2;
begin

ReadBuf[StatusByte] := 0;

Edit4.text := 'First GetStatus';

if GetStatus(TestId) = TxTimeOut then Exit;

Edit4.text := 'Resetting FPGAs';
Reset:
If WriteCommand(TestId,ResetFPGACmd) = TxTimeOut then
   begin
     if NoTxDialogue(TestId) = False then
       begin
         exit;
       end
     else
       begin
         goto Reset;
       end;
    end;

WaitAfterBroadCast(FPGALoopDelay);

edit4.text := 'Testing if FPGA is reset';

If GetStatus(TestId) = TxTimeout then
   begin
     exit;
   end;

edit4.text := 'FPGA Status Byte :- ' + Inttostr(ReadBuf[StatusByte]);
if (ReadBuf[StatusByte] and BinMask[4] = 0) then
  begin
      if NoResetDialogue(TestId,1) = false then
        begin
          Exit;
        end
     else
        begin
           goto Reset;
        end;
   end;

if (ReadBuf[StatusByte] and BinMask[5]  = 0 ) then
   begin
     if NoResetDialogue(TestId,2) = false then
        begin
          Exit;
        end
     else
        begin
           goto Reset;
        end;
    end;


FPGALOAD1:

edit4.text := 'Configuring FPGA 1 ';

if WriteFPGAFile(TestId,1) = TxTimeOut then
    begin
       If NoTxDialogue(TestId) = true then
         begin
           goto FPGALOAD1;
         end
       else
         begin
           exit;
         end;
     end;

edit4.text := 'Waiting for FPGA 1 to load configuration file';

WaitAfterBroadCast(FPGALoopDelay);

edit4.text := 'Checking for success of FPGA 1 configuration';

if GetStatus(TestId) = TxTimeOut then
    begin
      Exit;
    end;


if ((ReadBuf[StatusByte] and BinMask[6]) = 0) then
   begin
     if NoProgramDialogue(TestId,1) = false then
        begin
          Exit;
        end
      else
        begin
           goto FPGALOAD1;
        end;
    end;

FPGALOAD2:

edit4.text := 'Configuring FPGA 2';


if WriteFPGAFile(TestId,2) = TxTimeOut then
   begin
       If NoTxDialogue(TestId) = true then
         begin
           goto FPGALOAD2;
         end
       else
         begin
           exit;
         end;
     end;

edit4.text := 'Waiting for FPGA 2 to load configuration file';

WaitAfterBroadCast(FPGALoopDelay);

edit4.text := 'Checking for success of FPGA 2 configuration';

if GetStatus(TestId) = TxTimeOut then
   begin
     Exit;
   end;

if ((ReadBuf[StatusByte] and BinMask[7]) = 0) then
    begin
     if NoProgramDialogue(TestId,2) = false then
        begin
          Exit;
        end
     else
        begin
           goto FPGALOAD2;
        end;
     end;
end;

procedure TMain.FormCreate(Sender: TObject);
var F1: file;
    f2: file;
    filename : string;
    LoopCount: Integer;
    RBPch :PChar;
    RBuf: Char;

begin
   ReadSize := 1;
   main.top := 6;
   main.left := 6;
   FPGALoopDelay := 60000;
   ReadLoopDelay := 4000;
   WriteLoopDelay := 4000;
   WaitDelay:= 4500000;

for loopcount := 0 to 7 do
  begin
      BinMask[loopcount] := 0;
  end;

   BinMask[0] := 1;
   BinMask[1] := 2;
   BinMask[2] := 4;
   BinMask[3] := 8;
   BinMask[4] := 16;
   BinMask[5] := 32;
   BinMask[6] := 64;
   BinMask[7] := 128;

      Response := false;
      Response := false;

{Load Configfiles for testers in array}

{FILE 1 - FPGA 1}
      filename := 'Test1.cfg';
      if not FileExists(filename) then
          begin
          ShowMessage(' Config file' + filename + ' does not exist !!');
          exit;
          end;
      LoopCount := 1;
      AssignFile(F1, filename);
      FileMode := 0;  { Set file access to read only }
      Reset(F1, 1);
      while not Eof(F1) do
         begin
           BlockRead(F1,Buff1[LoopCount],1927);
           Loopcount := loopcount + 1927;
         end;
      CloseFile(F1);

{FILE 2 - FPGA 2}

     filename := 'Test2.cfg';
      if not FileExists(filename) then
          begin
          ShowMessage(' Config file' + filename + ' does not exist !!');
          exit;
          end;
      LoopCount := 1;
      AssignFile(F1, filename);
      FileMode := 0;  { Set file access to read only }
      Reset(F1,1);
      while not Eof(F1) do
         begin
           BlockRead(F1,Buff2[LoopCount],1927);
           Loopcount := loopcount + 1927;
         end;
    CloseFile(F1);
end;

procedure TMain.Timer1Timer(Sender: TObject);
begin

for MainLoop := 1 to 6 do
  begin
    TestId := MainLoop;
    if ActiveTester[TestId] = true then
      begin
        InterfChange(Sender);
        CheckInsError(Sender);
        CheckDtrChange(Sender);
        TestPatternSet(Sender);
        ExecCmd3Sync(Sender);
        ExecCmd30Status(Sender);
        ElapsTime(Sender);
        ReportErrors(Sender);
      end;
  end;
end;

function TMain.WriteToLatch(Id: Byte; Latch: Byte; DataByte: Byte) : Byte;
var TxResponse : Boolean;
begin
 WritenByte := Id;
 WriteByte(WritenByte);
 WritenByte := 4;         {Command 4   write to Latch}
 WriteByte(WritenByte);
 WritenByte := Latch;     {Latch}
 WriteByte(WritenByte);
 WritenByte := DataByte;  {Data Byte}
 WriteByte(WritenByte);
 CheckSum := Id + 4 + Latch + DataByte ;
 WritenByte := CheckSum;  {CheckSum}
 WriteByte(WritenByte);
 WriteToLatch := WaitForTx(WriteLoopDelay);
end;

function TMain.WriteFromLatch(Id: Byte; Command: Byte; Latch: Byte) : Byte;
var TxResponse : Boolean;
begin
 WritenByte := Id;
 WriteByte(WritenByte);
 WritenByte := Command;         {Command 3   write From Latch}
 WriteByte(WritenByte);
 WritenByte := Latch;     {Latch}
 WriteByte(WritenByte);
 CheckSum := Id + 3 + Latch;
 WritenByte := CheckSum;  {CheckSum}
 WriteByte(WritenByte);
 WriteFromLatch := WaitForTx(WriteLoopDelay);
end;

function TMain.GetRegisterResult(CommandRead : Byte) : Byte;
begin

if  not(ReadBuf[1] >= 0) or  not(ReadBuf[2] >= 0)  then  {ReadBuf Empty}
   begin
      exit;
   end;

Addr := ReadBuf[1];
Command := ReadBuf[2];

If CommandRead = 3 then
  begin
   DataByte := ReadBuf[3];
  end
else
  begin
   ErrorCount1 := ReadBuf[3];
   ErrorCount2 := ReadBuf[4];
  end;

GetRegisterResult := Ok;
end;

procedure TMain.CheckInsError(Sender: TObject);
var Response : Byte;
begin

if InsertError[TestId] = false then Exit;

InsertError[TestId] := false;

If WriteToLatch(TestId,5,16) = OK then
   begin
     Response := ReadFrame(3);
   end
else
   begin
     exit;
   end;

If Response = TxTimeOut then
  begin
    exit;
  end
else
  if Response = CheckSumErr then
    begin
      exit;
    end;

end;

procedure TMain.InterfChange(Sender: TObject);
var DataByte : Byte;
    Response : Byte;
begin

if InterfaceChange[TestId] = false then exit;
InterfaceChange[TestId] := false;

if InterfaceType[TestId] = 2 then     {V24}
   begin
     DataByte := 0;
   end
else
if InterfaceType[TestId] = 3 then   {V35}
   begin
     DataByte := 1;
   end
else
if InterfaceType[TestId] = 1 then    {V11}
   begin
     DataByte := 2;
   end;

If WriteToLatch(TestId,4,DataByte) = Ok then
   begin
      Response := ReadFrame(3);
   end
else
   begin
     exit;
   end;

If Response = TxTimeOut then
  begin
    exit;
  end
else
  if Response = CheckSumErr then
    begin
      exit;
    end;
end;


procedure TMain.CheckDtrChange(Sender: TObject);
begin

{     end; }


end;

procedure TMain.TestPatternSet(Sender: TObject);
var DataByte : Byte;
    Response : Byte;
begin

if TestPatChange[TestId] = false then exit;
TestPatChange[TestId] := false;

if TestPattern[TestId] = 1 then            {Pattern 511}
  begin
    DataByte := 0;
  end
else if TestPattern[TestId] = 2 then       {Pattern 2^10}
  begin
    DataByte := 4;
  end
else if TestPattern[TestId] = 3 then       {Pattern 2^13}
  begin
    DataByte := 6;
  end
else if TestPattern[TestId] = 4 then        {Pattern 2^20}
  begin
    DataByte := 2;
  end
else
  begin
    DataByte := 0;  {Defaults to   }
  end;

If WriteToLatch(TestId,0,DataByte) <> Ok then
   begin
      exit;
   end;

Response := ReadFrame(3);
If Response = RxTimeOut then
  begin
    exit;
  end
else
  if Response = CheckSumErr then
    begin
      exit;
    end;
end;


procedure TMain.ExecCmd3Sync(Sender: TObject);   {Getting SYNC Status}
var response : byte;
begin

if WriteFromLatch(TestId,3,1) <> Ok then
   begin
      exit;
   end;

Response := ReadFrame(4);

If Response = RxTimeOut then
  begin
    exit;
  end
else
  if Response = CheckSumErr then
    begin
      exit;
    end;

if GetRegisterResult(3) <> Ok then
    begin
      exit;
    end;

if (DataByte and BinMask[0]) <> 0  then
    begin
      SyncLoss:= true;
    end
else
    begin
       exit;
    end;

If addr = 1 then
        begin
          TesWin1.SyncInd.color := clRed;
          TesWin1.SyncInd.text := 'Sync Loss';
        end
else if addr = 2 then
        begin
          TesWin2.SyncInd.color := clRed;
          TesWin2.SyncInd.text := 'Sync Loss';
        end
else if addr = 3 then
        begin
          TesWin3.SyncInd.color := clRed;
          TesWin3.SyncInd.text := 'Sync Loss';
        end
else if addr = 4 then
        begin
          TesWin4.SyncInd.color := clRed;
          TesWin4.SyncInd.text := 'Sync Loss';
          end
else if addr = 5 then
        begin
          TesWin5.SyncInd.color := clRed;
          TesWin5.SyncInd.text := 'Sync Loss';
          end
else if addr = 6 then
        begin
          TesWin6.SyncInd.color := clRed;
          TesWin6.SyncInd.text := 'Sync Loss';
          end;
end;


procedure TMain.ExecCmd30Status(Sender: TObject);
var Response : Byte;
begin

if WriteFromLatch(TestId,3,0) <> Ok then
   begin
      exit;
   end;

Response := ReadFrame(4);

If Response = RxTimeOut then
  begin
    exit;
  end
else
  if Response = CheckSumErr then
    begin
      exit;
    end;

if GetRegisterResult(3) <> Ok then
    begin
      exit;
    end;

For LoopCount := 0 to 7 do
        begin
          StatusInd[LoopCount] := false;
        end;

if (DataByte and BinMask[0]) <> 0 then
     StatusInd[0] := true;
if (DataByte and BinMask[1]) <> 0 then
     StatusInd[1] := true;
if (DataByte and BinMask[2]) <> 0 then
     StatusInd[2] := true;
if (DataByte and BinMask[3]) <> 0 then
     StatusInd[3] := true;
if (DataByte and BinMask[4]) <> 0 then
     StatusInd[4] := true;
if (DataByte and BinMask[5]) <> 0 then
     StatusInd[5] := true;
if (DataByte and BinMask[6]) <> 0 then
     StatusInd[6] := true;
if (DataByte and BinMask[7]) <> 0 then
     StatusInd[7] := true;

If addr = 1 then
        begin
          UpdateTest1(Sender);
        end
else if addr = 2 then
        begin
          UpdateTest2(Sender);
        end
else if addr = 3 then
        begin
          UpdateTest3(Sender);
        end
else if addr = 4 then
        begin
          UpdateTest4(Sender);
        end
else if addr = 5 then
        begin
          UpdateTest5(Sender);
        end
else if addr = 6 then
        begin
          UpdateTest6(Sender);
        end;

end;

function TMain.WriteErrorCount(Id: Byte) : Byte;
var TxResponse : Boolean;
begin
 WritenByte := Id;
 WriteByte(WritenByte);
 WritenByte := 5;         {Command 5 - Get ErrorStatus}
 WriteByte(WritenByte);
 CheckSum := Id + 5;
 WritenByte := CheckSum;  {CheckSum}
 WriteByte(WritenByte);
 WriteErrorCount := WaitForTx(WriteLoopDelay);
end;

procedure TMain.ReportErrors(Sender: TObject);
var RecErrInt: integer;
    Response: Byte;
begin
if WriteErrorCount(TestId) <> Ok then
   begin
      exit;
   end;

Response := ReadFrame(4);

If Response = RxTimeOut then
  begin
    exit;
  end
else
  if Response = CheckSumErr then
    begin
      exit;
    end;

if GetRegisterResult(5) <> Ok then
    begin
      exit;
    end;

 RecErrInt:= ErrorCount1;
 RecErrInt := RecErrInt shl RecErrInt;
 RecErrInt := RecErrInt + ErrorCount2;

If addr = 1 then
        begin
           ErrCount[1] := ErrCount[1] + RecErrInt;
           if ErrCount[1] < 10 then
              begin
                 TesWin1.BitErrors.text := '     ' +inttostr(ErrCount[1]);
              end
           else if ErrCount[1] < 100 then
              begin
                 TesWin1.BitErrors.text := '   ' +inttostr(ErrCount[1]);
              end
           else if ErrCount[1] < 1000 then
              begin
                 TesWin1.BitErrors.text := '  ' +inttostr(ErrCount[1]);
              end
           else if ErrCount[1] < 10000 then
              begin
                 TesWin1.BitErrors.text := inttostr(ErrCount[1]);
              end
         end
else if addr = 2 then
        begin
          ErrCount[2] := ErrCount[2] + RecErrInt;
           TesWin2.BitErrors.text := inttostr(ErrCount[2]);
        end
else if addr = 3 then
        begin
          ErrCount[3] := ErrCount[3] + RecErrInt;
           TesWin3.BitErrors.text := inttostr(ErrCount[3]);
        end
else if addr = 4 then
        begin
          ErrCount[4] := ErrCount[4] + RecErrInt;
           TesWin4.BitErrors.text := inttostr(ErrCount[4]);
          end
else if addr = 5 then
        begin
          ErrCount[5] := ErrCount[5] + RecErrInt;
           TesWin5.BitErrors.text := inttostr(ErrCount[5]);
          end
else if addr = 6 then
        begin
          ErrCount[6] := ErrCount[6] + RecErrInt;
          TesWin6.BitErrors.text := inttostr(ErrCount[6]);
          end;

If addr = 1 then
        begin
           if ErrCount[1] = 99999 then ErrCount[1] := 0;
         end
else if addr = 2 then
        begin
           if ErrCount[2] = 99999 then ErrCount[2] := 0;
        end
else if addr = 3 then
        begin
          if ErrCount[3] = 99999 then ErrCount[3] := 0;
        end
else if addr = 4 then
        begin
           if ErrCount[4] = 99999 then ErrCount[4] := 0;
        end
else if addr = 5 then
        begin
           if ErrCount[5] = 99999 then ErrCount[5] := 0;
        end
else if addr = 6 then
        begin
           if ErrCount[6] = 99999 then ErrCount[6] := 0;
        end;

end;

procedure TMain.ElapsTime(Sender: TObject);
var calctime: longint;
    cnn1: longint;
    css1: longint;
    real1: real;
begin
     hh := copy(TimeStart[TestId], 1, 2);
     mm := copy(TimeStart[TestId], 4, 2);
     ss := copy(TimeStart[TestId], 7, 2);
     shi := strtoint(hh);
     smi := strtoint(mm);
     ssi := strtoint(ss);
     nowtime := TimeToStr(now);
     hh := copy(nowtime, 1, 2);
     mm := copy(nowtime, 4, 2);
     ss := copy(nowtime, 7, 2);
     nhi := strtoint(hh);
     nmi := strtoint(mm);
     nsi := strtoint(ss);


if shi > nhi then
    begin
      calctime := 86400 - ((shi * 3600) + (smi*60) + ssi );
      calctime := calctime + ((nhi * 3600) + (nmi * 60) + nsi);
    end
else
if shi <= nhi then
    begin
      calctime := (nhi * 3600) + (nmi * 60) + nsi;
      cnn1 := calctime;
      calctime := (shi * 3600) + (smi * 60) + ssi;
      css1 := calctime;
      calctime := cnn1 - css1;
    end;

 if calctime >= 3600 then
     begin
        real1 := int(calctime / 3600);
        nhi := trunc(real1);
        calctime := calctime - (nhi * 3600);
     end
 else
     begin
        nhi := 0;
     end;

 if calctime >= 60 then
     begin
        real1 := int (calctime / 60);
        nmi := trunc(real1);
        calctime := calctime - (nmi * 60);
     end
 else
     begin
        nmi := 0;
     end;

 nsi := calctime;

     if nhi < 10 then
       begin
        hh := '0' + inttostr(nhi);
       end
     else if nhi > 9 then
        begin
          hh := inttostr(nhi);
        end;
     if nmi < 10 then
       begin
        mm := '0' + inttostr(nmi);
       end
     else if nmi > 9 then
        begin
          mm := inttostr(nmi);
        end;
     if nsi < 10 then
       begin
        ss := '0' + inttostr(nsi);
       end
     else if nsi > 9 then
        begin
          ss := inttostr(nsi);
        end;
     nowtime := hh + ':' + mm + ':' + ss;
     if TestId = 1 then K6Line1.TesWin1.TimeElapse.Text :=  Nowtime;
     if TestId = 2 then K6Line2.TesWin2.TimeElapse.Text :=  Nowtime;
     if TestId = 3 then K6Line3.TesWin3.TimeElapse.Text :=  Nowtime;
     if TestId = 4 then K6Line4.TesWin4.TimeElapse.Text :=  Nowtime;
     if TestId = 5 then K6Line5.TesWin5.TimeElapse.Text :=  Nowtime;
     if TestId = 6 then K6Line6.TesWin6.TimeElapse.Text :=  Nowtime;
end;

procedure TMain.ComSetup(Sender: TObject);
begin

ReadBufferSize:= 1000;
WriteBufferSize:= 3900;
hComm:=OpenComm(CommStr,ReadBufferSize,WriteBufferSize);

DCB.Parity:= 0;
DCB.BaudRate:=19200;
DCB.ByteSize:=8;
DCB.StopBits:= 0;
DCB.Id:=hcomm;


DCB.Flags := DCB.FLAGS or (+ $8000 + $4000 + $0100 + $0080 + $0040);

SetCommState(DCB);

if GetCommState(hComm,DCB) <> 0 then
  begin
    showMessage('-Setting Failed -' +
               (' baudrate :' + inttostr(DCB.Baudrate) +
               (' byteReadSize : 8'  + '  parity : None' +
               (' hcomm :' + inttostr(DCB.id)))));
    EscapeCommFunction(hComm, 1);
    GetCommState(hComm,DCB);
    MessageDlg(' Check the Hardware and Check that no other Applications' +
             ' is using the selected Port', mtInformation, [mbOk], 0);
  end
else
  begin


  edit4.text := 'After FPGA 2 Loading Before Getstatus :( Status Byte = '
              + Inttostr(ReadBuf[StatusByte])+ ' )';



     edit4.text := ('Comms Setting:-' +
               (' Baudrate:' + inttostr(DCB.Baudrate) +
               (' ByteSize: 8'  + ' Parity: None')));
    FlushComm(hComm,1);
    FlushComm(hComm,0);
  end;
end;

procedure TMain.Com11Click(Sender: TObject);
var temp : pchar;
begin
   CloseComm(hComm);
   CommStr :='COM1:';
   ComSetup(Sender);
   Com11.Checked := true;
   Com21.Checked := false;
   Com31.Checked := false;
   Setup1.Visible := true;
   temp := 'com1: 19200,n,8,1';
   if BuildCommdcb(temp,DCB) <> 0 then
   begin
     ShowMessage('DCB BUILD unsuccessfull');
   end;
   SetCommState(DCB);

   end;

procedure TMain.Com21Click(Sender: TObject);
var temp : pchar;
begin
   CloseComm(hComm);
   CommStr :='COM2:';
   ComSetup(Sender);
   Com21.Checked := true;
   Com11.Checked := false;
   Com31.Checked := false;
   Setup1.Visible := true;
   temp := 'com2: 19,n,8,1';
   if BuildCommdcb(temp,DCB) <> 0 then
    begin
     ShowMessage('DCB BUILD unsuccessfull');
   end;
   SetCommState(DCB);
end;

procedure TMain.Com31Click(Sender: TObject);
begin
   CloseComm(hComm);
   CommStr :='COM3:';
   ComSetup(Sender);
   Com31.Checked := true;
   Com11.Checked := false;
   Com21.Checked := false;
   Setup1.Visible := true;

end;

procedure TMain.N2501Click(Sender: TObject);
begin
  Timer1.Interval := 150;
  N2501.Checked := true;
  N5001.Checked := false;
  N25001.Checked := false;
  N50001.Checked := false;
  N75001.Checked := false;
  N1Sec1.Checked := false;
  Port1.Visible := true;
end;

procedure TMain.N5001Click(Sender: TObject);
begin
  Timer1.Interval := 200;
  N2501.Checked := false;
  N5001.Checked := true;
  N25001.Checked := false;
  N50001.Checked := false;
  N75001.Checked := false;
  N1Sec1.Checked := false;
  Port1.Visible := true;
end;

procedure TMain.N25001Click(Sender: TObject);
begin
  Timer1.Interval := 250;
  N2501.Checked := false;
  N5001.Checked := false;
  N25001.Checked := true;
  N50001.Checked := false;
  N75001.Checked := false;
  N1Sec1.Checked := false;
  Port1.Visible := true;
end;

procedure TMain.N50001Click(Sender: TObject);
begin
  Timer1.Interval := 500;
  N2501.Checked := false;
  N5001.Checked := false;
  N25001.Checked := false;
  N50001.Checked := true;
  N75001.Checked := false;
  N1Sec1.Checked := false;
  Port1.Visible := true;
end;

procedure TMain.N75001Click(Sender: TObject);
begin
  Timer1.Interval := 750;
  N2501.Checked := false;
  N5001.Checked := false;
  N25001.Checked := false;
  N50001.Checked := false;
  N75001.Checked := true;
  N1Sec1.Checked := false;
  Port1.Visible := true;
end;

procedure TMain.N1Sec1Click(Sender: TObject);
begin
   Timer1.Interval := 1000;
   N2501.Checked := false;
   N5001.Checked := false;
   N25001.Checked := false;
   N50001.Checked := false;
   N75001.Checked := false;
   N1Sec1.Checked := true;
   Port1.Visible := true;
end;

procedure TMain.UpdateSync1(Sender: TObject);
begin
   TesWin1.SyncInd.text := 'Sync Loss';
   TesWin1.Font.Color := ClRed;
end;

procedure TMain.UpdateSync2(Sender: TObject);
begin
   TesWin2.SyncInd.text := 'Sync Loss';
   TesWin2.Font.Color := ClRed;
end;

procedure TMain.UpdateSync3(Sender: TObject);
begin
   TesWin3.SyncInd.text := 'Sync Loss';
   TesWin3.Font.Color := ClRed;
end;

procedure TMain.UpdateSync4(Sender: TObject);
begin
   TesWin4.SyncInd.text := 'Sync Loss';
   TesWin4.Font.Color := ClRed;
end;

procedure TMain.UpdateSync5(Sender: TObject);
begin
   TesWin5.SyncInd.text := 'Sync Loss';
   TesWin5.Font.Color := ClRed;
end;

procedure TMain.UpdateSync6(Sender: TObject);
begin
   TesWin6.SyncInd.text := 'Sync Loss';
   TesWin6.Font.Color := ClRed;
end;


procedure TMain.UpdateTest1(Sender: TObject);
begin

if InterfaceType[TestId] = 2 then    {V24}
    begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin1.IntInd8.color := clgreen;
         end;
      if StatusInd[1] = true then         {CD}
          begin
           TesWin1.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {114}
          begin
            TesWin1.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {115}
          begin
            TesWin1.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {TD}
          begin
            TesWin1.IntInd4.color := clgreen;
          end;
      if StatusInd[5] = true then         {DSR}
          begin
            TesWin1.IntInd5.color := clgreen;
          end;
      if StatusInd[6] = true then         {CTS}
          begin
            TesWin1.IntInd6.color := clgreen;
          end;
      if StatusInd[7] = true then         {142}
          begin
            TesWin1.IntInd12.color := clgreen;
          end;
    end
  else
    if InterfaceType[TestId] = 3 then     {35}
      begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin1.IntInd8.color := clgreen;
         end;
      if StatusInd[1] = true then         {CD}
          begin
           TesWin1.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {114}
          begin
            TesWin1.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {115}
          begin
            TesWin1.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {TD}
          begin
            TesWin1.IntInd4.color := clgreen;
          end;
      if StatusInd[5] = true then         {DSR}
          begin
            TesWin1.IntInd5.color := clgreen;
          end;
      if StatusInd[6] = true then         {CTS}
          begin
            TesWin1.IntInd6.color := clgreen;
          end;
      if StatusInd[7] = true then         {142}
          begin
            TesWin1.IntInd12.color := clgreen;
          end;
    end
  else
  if InterfaceType[TestId] = 1 then         {V11}
    begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin1.IntInd6.color := clgreen;
         end;
      if StatusInd[1] = true then         {CTRL}
          begin
           TesWin1.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {TD}
          begin
            TesWin1.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {INDC}
          begin
            TesWin1.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {SCLK}
          begin
            TesWin1.IntInd4.color := clgreen;
          end;
    end;

{RED RED RED RED RED}
if InterfaceType[TestId] = 2 then    {V24}
    begin
      if StatusInd[0] <> true then          {RD}
         begin
           TesWin1.IntInd8.color := clRed;
         end;
      if StatusInd[1] <> true then         {CD}
          begin
           TesWin1.IntInd7.color := clRed;
          end;
      if StatusInd[2] <> true then         {114}
          begin
            TesWin1.IntInd9.color := clRed;
          end;
      if StatusInd[3] <> true  then         {115}
          begin
            TesWin1.IntInd0.color := clRed;
          end;
      if StatusInd[4] <> true then         {TD}
          begin
            TesWin1.IntInd4.color := clRed;
          end;
      if StatusInd[5]  <> true  then         {DSR}
          begin
            TesWin1.IntInd5.color := clRed;
          end;
      if StatusInd[6] <> true then         {CTS}
          begin
            TesWin1.IntInd6.color := clRed;
          end;
      if StatusInd[7] <> true then         {142}
          begin
            TesWin1.IntInd12.color := clRed;
          end;
    end
  else
    if InterfaceType[TestId] = 3 then     {35}
      begin
      if StatusInd[0] <> true  then          {RD}
         begin
           TesWin1.IntInd8.color := clRed;
         end;
      if StatusInd[1]  <> true  then         {CD}
          begin
           TesWin1.IntInd7.color := clRed;
          end;
      if StatusInd[2]  <> true  then         {114}
          begin
            TesWin1.IntInd9.color := clRed;
          end;
      if StatusInd[3] <> true  then         {115}
          begin
            TesWin1.IntInd0.color := clRed;
          end;
      if StatusInd[4]  <> true then         {TD}
          begin
            TesWin1.IntInd4.color := clRed;
          end;
      if StatusInd[5]  <> true  then         {DSR}
          begin
            TesWin1.IntInd5.color := clRed;
          end;
      if StatusInd[6]  <> true  then         {CTS}
          begin
            TesWin1.IntInd6.color := clRed;
          end;
      if StatusInd[7] <> true  then         {142}
          begin
            TesWin1.IntInd12.color := clRed;
          end;
    end
  else
  if InterfaceType[TestId] = 1 then         {V11}
    begin
      if StatusInd[0]  <> true  then          {RD}
         begin
           TesWin1.IntInd6.color := clRed;
         end;
      if StatusInd[1]  <> true  then         {CTRL}
          begin
           TesWin1.IntInd7.color := clRed;
          end;
      if StatusInd[2]  <> true  then         {TD}
          begin
            TesWin1.IntInd9.color := clRed;
          end;
      if StatusInd[3] <> true  then         {INDC}
          begin
            TesWin1.IntInd0.color := clRed;
          end;
      if StatusInd[4]  <> true  then         {SCLK}
          begin
            TesWin1.IntInd4.color := clRed;
          end;
    end;
end;

procedure TMain.UpdateTest2(Sender: TObject);
begin
  if InterfaceType[TestId] = 2 then    {V24}
    begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin2.IntInd8.color := clgreen;
         end;
      if StatusInd[1] = true then         {CD}
          begin
           TesWin2.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {114}
          begin
            TesWin2.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {115}
          begin
            TesWin2.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {TD}
          begin
            TesWin2.IntInd4.color := clgreen;
          end;
      if StatusInd[5] = true then         {DSR}
          begin
            TesWin2.IntInd5.color := clgreen;
          end;
      if StatusInd[6] = true then         {CTS}
          begin
            TesWin2.IntInd6.color := clgreen;
          end;
      if StatusInd[7] = true then         {142}
          begin
            TesWin2.IntInd12.color := clgreen;
          end;
    end
  else
    if InterfaceType[TestId] = 3 then     {35}
      begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin2.IntInd8.color := clgreen;
         end;
      if StatusInd[1] = true then         {CD}
          begin
           TesWin2.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {114}
          begin
            TesWin2.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {115}
          begin
            TesWin2.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {TD}
          begin
            TesWin2.IntInd4.color := clgreen;
          end;
      if StatusInd[5] = true then         {DSR}
          begin
            TesWin2.IntInd5.color := clgreen;
          end;
      if StatusInd[6] = true then         {CTS}
          begin
            TesWin2.IntInd6.color := clgreen;
          end;
      if StatusInd[7] = true then         {142}
          begin
            TesWin2.IntInd12.color := clgreen;
          end;
    end
  else
  if InterfaceType[TestId] = 1 then         {V11}
    begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin2.IntInd6.color := clgreen;
         end;
      if StatusInd[1] = true then         {CTRL}
          begin
           TesWin2.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {TD}
          begin
            TesWin2.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {INDC}
          begin
            TesWin2.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {SCLK}
          begin
            TesWin2.IntInd4.color := clgreen;
          end;
    end;
 if InterfaceType[TestId] = 2 then    {V24}
    begin
      if StatusInd[0] <> true then          {RD}
         begin
           TesWin2.IntInd8.color := clRed;
         end;
      if StatusInd[1]  <> true  then         {CD}
          begin
           TesWin2.IntInd7.color := clRed;
          end;
      if StatusInd[2]  <> true  then         {114}
          begin
            TesWin2.IntInd9.color := clRed;
          end;
      if StatusInd[3]  <> true  then         {115}
          begin
            TesWin2.IntInd0.color := clRed;
          end;
      if StatusInd[4]  <> true then         {TD}
          begin
            TesWin2.IntInd4.color := clRed;
          end;
      if StatusInd[5]  <> true  then         {DSR}
          begin
            TesWin2.IntInd5.color := clRed;
          end;
      if StatusInd[6]  <> true  then         {CTS}
          begin
            TesWin2.IntInd6.color := clRed;
          end;
      if StatusInd[7]  <> true  then         {142}
          begin
            TesWin2.IntInd12.color := clRed;
          end;
    end
  else
    if InterfaceType[TestId] = 3 then     {35}
      begin
      if StatusInd[0]  <> true  then          {RD}
         begin
           TesWin2.IntInd8.color := clRed;
         end;
      if StatusInd[1] <> true  then         {CD}
          begin
           TesWin2.IntInd7.color := clRed;
          end;
      if StatusInd[2]  <> true  then         {114}
          begin
            TesWin2.IntInd9.color := clRed;
          end;
      if StatusInd[3]  <> true then         {115}
          begin
            TesWin2.IntInd0.color := clRed;
          end;
      if StatusInd[4]  <> true  then         {TD}
          begin
            TesWin2.IntInd4.color := clRed;
          end;
      if StatusInd[5]  <> true then         {DSR}
          begin
            TesWin2.IntInd5.color := clRed;
          end;
      if StatusInd[6] <> true  then         {CTS}
          begin
            TesWin2.IntInd6.color := clRed;
          end;
      if StatusInd[7]  <> true  then         {142}
          begin
            TesWin2.IntInd12.color := clRed;
          end;
    end
  else
  if InterfaceType[TestId] = 1 then         {V11}
    begin
      if StatusInd[0] <> true  then          {RD}
         begin
           TesWin2.IntInd6.color := clRed;
         end;
      if StatusInd[1]  <> true then         {CTRL}
          begin
           TesWin2.IntInd7.color := clRed;
          end;
      if StatusInd[2] <> true  then         {TD}
          begin
            TesWin2.IntInd9.color := clRed;
          end;
      if StatusInd[3]  <> true  then         {INDC}
          begin
            TesWin2.IntInd0.color := clRed;
          end;
      if StatusInd[4] <> true  then         {SCLK}
          begin
            TesWin2.IntInd4.color := clRed;
          end;
    end;

end;

procedure TMain.UpdateTest3(Sender: TObject);
begin
  if InterfaceType[TestId] = 2 then    {V24}
    begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin3.IntInd8.color := clgreen;
         end;
      if StatusInd[1] = true then         {CD}
          begin
           TesWin3.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {114}
          begin
            TesWin3.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {115}
          begin
            TesWin3.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {TD}
          begin
            TesWin3.IntInd4.color := clgreen;
          end;
      if StatusInd[5] = true then         {DSR}
          begin
            TesWin3.IntInd5.color := clgreen;
          end;
      if StatusInd[6] = true then         {CTS}
          begin
            TesWin3.IntInd6.color := clgreen;
          end;
      if StatusInd[7] = true then         {142}
          begin
            TesWin3.IntInd12.color := clgreen;
          end;
    end
  else
    if InterfaceType[TestId] = 3 then     {35}
      begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin3.IntInd8.color := clgreen;
         end;
      if StatusInd[1] = true then         {CD}
          begin
           TesWin3.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {114}
          begin
            TesWin3.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {115}
          begin
            TesWin3.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {TD}
          begin
            TesWin3.IntInd4.color := clgreen;
          end;
      if StatusInd[5] = true then         {DSR}
          begin
            TesWin3.IntInd5.color := clgreen;
          end;
      if StatusInd[6] = true then         {CTS}
          begin
            TesWin3.IntInd6.color := clgreen;
          end;
      if StatusInd[7] = true then         {142}
          begin
            TesWin3.IntInd12.color := clgreen;
          end;
    end
  else
  if InterfaceType[TestId] = 1 then         {V11}
    begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin3.IntInd6.color := clgreen;
         end;
      if StatusInd[1] = true then         {CTRL}
          begin
           TesWin3.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {TD}
          begin
            TesWin3.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {INDC}
          begin
            TesWin3.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {SCLK}
          begin
            TesWin3.IntInd4.color := clgreen;
          end;
    end;

  if InterfaceType[TestId] = 2 then    {V24}
    begin
      if StatusInd[0] <> true then          {RD}
         begin
           TesWin3.IntInd8.color := clRed;
         end;
      if StatusInd[1] <> true then         {CD}
          begin
           TesWin3.IntInd7.color := clRed;
          end;
      if StatusInd[2] <> true then         {114}
          begin
            TesWin3.IntInd9.color := clRed;
          end;
      if StatusInd[3] <> true then         {115}
          begin
            TesWin3.IntInd0.color := clRed;
          end;
      if StatusInd[4] <> true then         {TD}
          begin
            TesWin3.IntInd4.color := clRed;
          end;
      if StatusInd[5] <> true then         {DSR}
          begin
            TesWin3.IntInd5.color := clRed;
          end;
      if StatusInd[6] <> true then         {CTS}
          begin
            TesWin3.IntInd6.color := clRed;
          end;
      if StatusInd[7] <> true then         {142}
          begin
            TesWin3.IntInd12.color := clRed;
          end;
    end
  else
    if InterfaceType[TestId] = 3 then     {35}
      begin
      if StatusInd[0] <> true then          {RD}
         begin
           TesWin3.IntInd8.color := clRed;
         end;
      if StatusInd[1] <> true then         {CD}
          begin
           TesWin3.IntInd7.color := clRed;
          end;
      if StatusInd[2] <> true then         {114}
          begin
            TesWin3.IntInd9.color := clRed;
          end;
      if StatusInd[3] <> true then         {115}
          begin
            TesWin3.IntInd0.color := clRed;
          end;
      if StatusInd[4] <> true then         {TD}
          begin
            TesWin3.IntInd4.color := clRed;
          end;
      if StatusInd[5] <> true then         {DSR}
          begin
            TesWin3.IntInd5.color := clRed;
          end;
      if StatusInd[6] <> true then         {CTS}
          begin
            TesWin3.IntInd6.color := clRed;
          end;
      if StatusInd[7] <> true then         {142}
          begin
            TesWin3.IntInd12.color := clRed;
          end;
    end
  else
  if InterfaceType[TestId] = 1 then         {V11}
    begin
      if StatusInd[0] <> true then          {RD}
         begin
           TesWin3.IntInd6.color := clRed;
         end;
      if StatusInd[1] <> true then         {CTRL}
          begin
           TesWin3.IntInd7.color := clRed;
          end;
      if StatusInd[2] <> true then         {TD}
          begin
            TesWin3.IntInd9.color := clRed;
          end;
      if StatusInd[3] <> true then         {INDC}
          begin
            TesWin3.IntInd0.color := clRed;
          end;
      if StatusInd[4] <> true then         {SCLK}
          begin
            TesWin3.IntInd4.color := clRed;
          end;
    end;
end;

procedure TMain.UpdateTest4(Sender: TObject);
begin
   if InterfaceType[TestId] = 2 then    {V24}
    begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin4.IntInd8.color := clgreen;
         end;
      if StatusInd[1] = true then         {CD}
          begin
           TesWin4.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {114}
          begin
            TesWin4.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {115}
          begin
            TesWin4.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {TD}
          begin
            TesWin4.IntInd4.color := clgreen;
          end;
      if StatusInd[5] = true then         {DSR}
          begin
            TesWin4.IntInd5.color := clgreen;
          end;
      if StatusInd[6] = true then         {CTS}
          begin
            TesWin4.IntInd6.color := clgreen;
          end;
      if StatusInd[7] = true then         {142}
          begin
            TesWin4.IntInd12.color := clgreen;
          end;
    end
  else
    if InterfaceType[TestId] = 3 then     {35}
      begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin4.IntInd8.color := clgreen;
         end;
      if StatusInd[1] = true then         {CD}
          begin
           TesWin4.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {114}
          begin
            TesWin4.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {115}
          begin
            TesWin4.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {TD}
          begin
            TesWin4.IntInd4.color := clgreen;
          end;
      if StatusInd[5] = true then         {DSR}
          begin
            TesWin4.IntInd5.color := clgreen;
          end;
      if StatusInd[6] = true then         {CTS}
          begin
            TesWin4.IntInd6.color := clgreen;
          end;
      if StatusInd[7] = true then         {142}
          begin
            TesWin4.IntInd12.color := clgreen;
          end;
    end
  else
  if InterfaceType[TestId] = 1 then         {V11}
    begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin4.IntInd6.color := clgreen;
         end;
      if StatusInd[1] = true then         {CTRL}
          begin
           TesWin4.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {TD}
          begin
            TesWin4.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {INDC}
          begin
            TesWin4.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {SCLK}
          begin
            TesWin4.IntInd4.color := clgreen;
          end;
    end;
  if InterfaceType[TestId] = 2 then    {V24}
    begin
      if StatusInd[0] <> true then          {RD}
         begin
           TesWin4.IntInd8.color := clRed;
         end;
      if StatusInd[1] <> true then         {CD}
          begin
           TesWin4.IntInd7.color := clRed;
          end;
      if StatusInd[2] <> true then         {114}
          begin
            TesWin4.IntInd9.color := clRed;
          end;
      if StatusInd[3] <> true then         {115}
          begin
            TesWin4.IntInd0.color := clRed;
          end;
      if StatusInd[4] <> true then         {TD}
          begin
            TesWin4.IntInd4.color := clRed;
          end;
      if StatusInd[5] <> true then         {DSR}
          begin
            TesWin4.IntInd5.color := clRed;
          end;
      if StatusInd[6] <> true then         {CTS}
          begin
            TesWin4.IntInd6.color := clRed;
          end;
      if StatusInd[7] <> true then         {142}
          begin
            TesWin4.IntInd12.color := clRed;
          end;
    end
  else
    if InterfaceType[TestId] = 3 then     {35}
      begin
      if StatusInd[0] <> true then          {RD}
         begin
           TesWin4.IntInd8.color := clRed;
         end;
      if StatusInd[1] <> true then         {CD}
          begin
           TesWin4.IntInd7.color := clRed;
          end;
      if StatusInd[2] <> true then         {114}
          begin
            TesWin4.IntInd9.color := clRed;
          end;
      if StatusInd[3] <> true then         {115}
          begin
            TesWin4.IntInd0.color := clRed;
          end;
      if StatusInd[4] <> true then         {TD}
          begin
            TesWin4.IntInd4.color := clRed;
          end;
      if StatusInd[5] <> true then         {DSR}
          begin
            TesWin4.IntInd5.color := clRed;
          end;
      if StatusInd[6] <> true then         {CTS}
          begin
            TesWin4.IntInd6.color := clRed;
          end;
      if StatusInd[7] <> true then         {142}
          begin
            TesWin4.IntInd12.color := clRed;
          end;
    end
  else
  if InterfaceType[TestId] = 1 then         {V11}
    begin
      if StatusInd[0] <> true then          {RD}
         begin
           TesWin4.IntInd6.color := clRed;
         end;
      if StatusInd[1] <> true then         {CTRL}
          begin
           TesWin4.IntInd7.color := clRed;
          end;
      if StatusInd[2] <> true then         {TD}
          begin
            TesWin4.IntInd9.color := clRed;
          end;
      if StatusInd[3] <> true then         {INDC}
          begin
            TesWin4.IntInd0.color := clRed;
          end;
      if StatusInd[4] <> true then         {SCLK}
          begin
            TesWin4.IntInd4.color := clRed;
          end;
    end;
end;

procedure TMain.UpdateTest5(Sender: TObject);
begin
   if InterfaceType[TestId] = 2 then    {V24}
    begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin5.IntInd8.color := clgreen;
         end;
      if StatusInd[1] = true then         {CD}
          begin
           TesWin5.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {114}
          begin
            TesWin5.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {115}
          begin
            TesWin5.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {TD}
          begin
            TesWin5.IntInd4.color := clgreen;
          end;
      if StatusInd[5] = true then         {DSR}
          begin
            TesWin5.IntInd5.color := clgreen;
          end;
      if StatusInd[6] = true then         {CTS}
          begin
            TesWin5.IntInd6.color := clgreen;
          end;
      if StatusInd[7] = true then         {142}
          begin
            TesWin5.IntInd12.color := clgreen;
          end;
    end
  else
    if InterfaceType[TestId] = 3 then     {35}
      begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin5.IntInd8.color := clgreen;
         end;
      if StatusInd[1] = true then         {CD}
          begin
           TesWin5.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {114}
          begin
            TesWin5.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {115}
          begin
            TesWin5.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {TD}
          begin
            TesWin5.IntInd4.color := clgreen;
          end;
      if StatusInd[5] = true then         {DSR}
          begin
            TesWin5.IntInd5.color := clgreen;
          end;
      if StatusInd[6] = true then         {CTS}
          begin
            TesWin5.IntInd6.color := clgreen;
          end;
      if StatusInd[7] = true then         {142}
          begin
            TesWin5.IntInd12.color := clgreen;
          end;
    end
  else
  if InterfaceType[TestId] = 1 then         {V11}
    begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin5.IntInd6.color := clgreen;
         end;
      if StatusInd[1] = true then         {CTRL}
          begin
           TesWin5.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {TD}
          begin
            TesWin5.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {INDC}
          begin
            TesWin5.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {SCLK}
          begin
            TesWin5.IntInd4.color := clgreen;
          end;
    end;
if InterfaceType[TestId] = 2 then    {V24}
    begin
      if StatusInd[0] <> true then          {RD}
         begin
           TesWin5.IntInd8.color := clRed;
         end;
      if StatusInd[1] <> true then         {CD}
          begin
           TesWin5.IntInd7.color := clRed;
          end;
      if StatusInd[2] <> true then         {114}
          begin
            TesWin5.IntInd9.color := clRed;
          end;
      if StatusInd[3] <> true then         {115}
          begin
            TesWin5.IntInd0.color := clRed;
          end;
      if StatusInd[4] <> true then         {TD}
          begin
            TesWin5.IntInd4.color := clRed;
          end;
      if StatusInd[5] <> true then         {DSR}
          begin
            TesWin5.IntInd5.color := clRed;
          end;
      if StatusInd[6] <> true then         {CTS}
          begin
            TesWin5.IntInd6.color := clRed;
          end;
      if StatusInd[7] <> true then         {142}
          begin
            TesWin5.IntInd12.color := clRed;
          end;
    end
  else
    if InterfaceType[TestId] = 3 then     {35}
      begin
      if StatusInd[0] <> true then          {RD}
         begin
           TesWin5.IntInd8.color := clRed;
         end;
      if StatusInd[1] <> true then         {CD}
          begin
           TesWin5.IntInd7.color := clRed;
          end;
      if StatusInd[2] <> true then         {114}
          begin
            TesWin5.IntInd9.color := clRed;
          end;
      if StatusInd[3] <> true then         {115}
          begin
            TesWin5.IntInd0.color := clRed;
          end;
      if StatusInd[4] <> true then         {TD}
          begin
            TesWin5.IntInd4.color := clRed;
          end;
      if StatusInd[5] <> true then         {DSR}
          begin
            TesWin5.IntInd5.color := clRed;
          end;
      if StatusInd[6] <> true then         {CTS}
          begin
            TesWin5.IntInd6.color := clRed;
          end;
      if StatusInd[7] <> true then         {142}
          begin
            TesWin5.IntInd12.color := clRed;
          end;
    end
  else
  if InterfaceType[TestId] = 1 then         {V11}
    begin
      if StatusInd[0] <> true then          {RD}
         begin
           TesWin5.IntInd6.color := clRed;
         end;
      if StatusInd[1] <> true then         {CTRL}
          begin
           TesWin5.IntInd7.color := clRed;
          end;
      if StatusInd[2] <> true then         {TD}
          begin
            TesWin5.IntInd9.color := clRed;
          end;
      if StatusInd[3] <> true then         {INDC}
          begin
            TesWin5.IntInd0.color := clRed;
          end;
      if StatusInd[4] <> true then         {SCLK}
          begin
            TesWin5.IntInd4.color := clRed;
          end;
    end;
end;

procedure TMain.UpdateTest6(Sender: TObject);
begin
    if InterfaceType[TestId] = 2 then    {V24}
    begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin6.IntInd8.color := clgreen;
         end;
      if StatusInd[1] = true then         {CD}
          begin
           TesWin6.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {114}
          begin
            TesWin6.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {115}
          begin
            TesWin6.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {TD}
          begin
            TesWin6.IntInd4.color := clgreen;
          end;
      if StatusInd[5] = true then         {DSR}
          begin
            TesWin6.IntInd5.color := clgreen;
          end;
      if StatusInd[6] = true then         {CTS}
          begin
            TesWin6.IntInd6.color := clgreen;
          end;
      if StatusInd[7] = true then         {142}
          begin
            TesWin6.IntInd12.color := clgreen;
          end;
    end
  else
    if InterfaceType[TestId] = 3 then     {35}
      begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin6.IntInd8.color := clgreen;
         end;
      if StatusInd[1] = true then         {CD}
          begin
           TesWin6.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {114}
          begin
            TesWin6.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {115}
          begin
            TesWin6.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {TD}
          begin
            TesWin6.IntInd4.color := clgreen;
          end;
      if StatusInd[5] = true then         {DSR}
          begin
            TesWin6.IntInd5.color := clgreen;
          end;
      if StatusInd[6] = true then         {CTS}
          begin
            TesWin6.IntInd6.color := clgreen;
          end;
      if StatusInd[7] = true then         {142}
          begin
            TesWin6.IntInd12.color := clgreen;
          end;
    end
  else
  if InterfaceType[TestId] = 1 then         {V11}
    begin
      if StatusInd[0] = true then          {RD}
         begin
           TesWin6.IntInd6.color := clgreen;
         end;
      if StatusInd[1] = true then         {CTRL}
          begin
           TesWin6.IntInd7.color := clgreen;
          end;
      if StatusInd[2] = true then         {TD}
          begin
            TesWin6.IntInd9.color := clgreen;
          end;
      if StatusInd[3] = true then         {INDC}
          begin
            TesWin6.IntInd0.color := clgreen;
          end;
      if StatusInd[4] = true then         {SCLK}
          begin
            TesWin6.IntInd4.color := clgreen;
          end;
    end;

end;

procedure TMain.DelayClick(Sender: TObject);
begin

 wAITdELAY := STRTOINT(eDIT99.TEXT);

end;
procedure TMain.Button1Click(Sender: TObject);
begin
  FPGALoopDelay:= strtoint(Edit3.text);
  ReadLoopDelay:= strtoint(Edit1.Text);
  WriteLoopDelay :=  strtoint(Edit2.text);
end;

end.


