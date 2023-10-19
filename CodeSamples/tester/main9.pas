unit Main9;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, K6Line1, K6Line2, K6Line3, K6Line4, K6Line5, K6Line6,
  K6Setup, ExtCtrls;

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
    procedure Exit1Click(Sender: TObject);
    procedure Line11Click(Sender: TObject);
    procedure Line21Click(Sender: TObject);
    procedure Line31Click(Sender: TObject);
    procedure Line41Click(Sender: TObject);
    procedure Line51Click(Sender: TObject);
    procedure Line61Click(Sender: TObject);
    procedure AllTesters1Click(Sender: TObject);
    procedure Com11Click(Sender: TObject);
    procedure Com21Click(Sender: TObject);
    procedure Com31Click(Sender: TObject);
    procedure ComClear(Sender: TObject);
    procedure ComSetup(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure InterfChange(Sender: TObject);
    procedure ElapsTime(Sender: TObject);
    procedure CheckInsError(Sender: TObject);
    procedure CheckDtrChange(Sender: TObject);
    procedure ExecCmd4(Sender: TObject);
    procedure ExecCmd30Status(Sender: TObject);
    procedure ExecCmd3Sync(Sender: TObject);
    procedure InitialiseTester(Sender: TObject);
    procedure CheckFPGAProgrammed(Sender: TObject);
    procedure CheckFPGAReady(Sender: TObject);
    procedure UpdateTest1(Sender: TObject);
    procedure UpdateTest2(Sender: TObject);
    procedure UpdateTest3(Sender: TObject);
    procedure UpdateTest4(Sender: TObject);
    procedure UpdateTest5(Sender: TObject);
    procedure UpdateTest6(Sender: TObject);
    procedure ReportErrors(Sender: TObject);
    procedure ResetCycle(Sender: TObject);
    procedure N25001Click(Sender: TObject);
    procedure N50001Click(Sender: TObject);
    procedure N75001Click(Sender: TObject);
    procedure N1Sec1Click(Sender: TObject);
    procedure ResetWin1(Sender: TObject);
    procedure ResetWin2(Sender: TObject);
    procedure ResetWin3(Sender: TObject);
    procedure ResetWin4(Sender: TObject);
    procedure ResetWin5(Sender: TObject);
    procedure ResetWin6(Sender: TObject);
    procedure N5001Click(Sender: TObject);
    procedure N2501Click(Sender: TObject);
    procedure UpdateSync1(Sender: TObject);
    procedure UpdateSync2(Sender: TObject);
    procedure UpdateSync3(Sender: TObject);
    procedure UpdateSync4(Sender: TObject);
    procedure UpdateSync5(Sender: TObject);
    procedure UpdateSync6(Sender: TObject);
    procedure WriteByte(Sender: TObject);
    procedure ReadCmdResponse(Sender: TObject);

private
    { Private declarations }
public
    { Public declarations }
  end;

var
  Main: TMain;
  time: TDateTime;
  UnitNo : byte;
  DCB:TDCB;
  Stat: TCOMSTAT;
  hComm: integer;
  CommStr: PChar;
  CommStr1: String[4];
  SyncLoss: Boolean;
  TimerCycle: Byte;
  ReadBufferSize: word;
  WriteBufferSize: word;
  CfgLength1: integer;
  CfgLength2: integer;
  looptime: longint;
  waittime: longint;
  hh: string[2];
  mm: string[2];
  ss: string[2];
  shi: shortint;
  smi: shortint;
  ssi: shortint;
  nhi: shortint;
  nmi: shortint;
  nsi: shortint;
  nowtime: string[8];
  LoopCount: integer;
  TestId: Byte;
  TempCheck : Byte;
  pCharStr: array [0..82] of char;
  StatusInd: array [0..7] of boolean;
  BinMask: array [0..7] of byte;
  Buff1: array [1..3855] of byte;
  Buff2: array [1..3855] of byte;
  FPGAReLoad: Boolean;
  FPGAReset : Boolean;
  PCh1 : Pchar;
  ReadBuf: byte;
  WritenByte: byte;
  buf: pchar;
  size: smallint;
  FailCnt: smallint;
  ReadByte: byte;
  InitFPGA: SmallInt;
  Response: Boolean;
  NoActTest : Byte;
  POPSTOP : BOOLEAN;
  discmd3 : boolean;
  discmd3c : boolean;

{Comm String Setup variables }
  Addr: byte;
  Command: byte;
  Latch: byte;
  DataLine: byte;
  CheckSum: byte;
  ErrorCount1: Byte;
  ErrorCount2: Byte;
 {  Line Setup and Parameters }
  ActiveTester: array [1..6] of boolean;
  Initialised: array [1..6] of boolean;
  InterfaceType : array [1..6] of byte;
  InterFaceChange : array [1..6] of boolean;
  TestPattern : array [1..6] of byte;
  TestPatChange : array [1..6] of boolean;
  LatchOffset: array [1..6] of integer;
  TimeStart: array [1..6] of string[8];
  InsertError: array [1..6] of boolean;
  DtrRtsSet: array [1..6] of boolean;
  DtrRstSel: array [1..6] of string[3];
  ErrCount : array [1..6] of integer;

implementation
{$R *.DFM}

procedure TMain.Exit1Click(Sender: TObject);
var  Button: Integer;
begin
  Button := Application.MessageBox('Are you sure you want to close ALL'+
  ' Testers ?', 'Closing the Main Tester Handler ', mb_OKCancel +
    mb_DefButton1);
 if Button = IDOK then
    close;
    CloseComm(hComm);
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
   TestId := 9;
   K6Line1.TesWin1.show;
   K6Line2.TesWin2.show;
   K6Line3.TesWin3.show;
   K6Line4.TesWin4.show;
   K6Line5.TesWin5.show;
   K6Line6.TesWin6.show;
   InitialiseTester(Sender);
end;

procedure TMain.InitialiseTester(Sender: TObject);
Label RESET1 , RELOAD1;
begin

RESET1:
FPGAReset := False;
{CHECK THIS OUT _ PER TESTER _ NIE NET ALMAL  !!!
if FPGALoaded = true then
   begin
   if MessageDlg('The Config files were loaded using broadcast. Do you really'+
    ' want to load it again ?',mtInformation, [mbYes, mbNo], 0) = mrNo then
     begin
       FPGA2Load := false;
       exit;
     end;
   end;                                     }

FlushComm(hComm,0);
FlushComm(hComm,1);

 if TestId = 9 then
   begin
     WritenByte := 0;  {All FPGA}
     TempCheck := 0;
   end
 else
   begin
     WritenByte := TestId;  {Specific Tester's  FPGA}
     TempCheck := TestId;
   end;

 WriteByte(Sender);
 WritenByte := 7;    {Command}
 WriteByte(Sender);
 CheckSum := 7 + TempCheck;
 WritenByte := CheckSum;      {CheckSum}
 WriteByte(Sender);

for looptime := 1 to 175000 do
     begin
       waittime := waittime + 1;
     end;


 {                ---- check FPGA status for READY To PROGRAM FPGA ------}
 if TestId = 9 then
   begin
     for loopcount := 1 to 6 do
        begin
          WritenByte := loopcount;  {All FPGA's responses for READY TO LOAD }
          TempCheck := loopcount;
          CheckFPGAReady(Sender);
        end;
   end
  else
   begin
     WritenByte := TestId;  {Specific Tester's FPGA response for READY TO LOAD}
     TempCheck := TestId;
     CheckFPGAReady(Sender);
   end;

 if FPGAReset = true then goto RESET1;


RELOAD1:

FPGAReload := False;
 if TestId = 9 then
   begin
     WritenByte := 0;  {Address - Broadcast to all testers}
     TempCheck := 0;
   end
 else
   begin
     WritenByte := TestId;  {Specific Tester's  FPGA}
     TempCheck := TestId;
   end;

 WriteByte(Sender);
 WritenByte := 1;    {Command}
 WriteByte(Sender);
 WriteComm(hComm, @Buff1, 3854);


for FailCnt := 1 to 100 do
   begin
    GetCommError(hComm,Stat);
     if stat.cbOutQue <> 0 then
       begin
         for looptime := 1 to 22000 do
           begin
             waittime := waittime + 1;
           end;
        end;
     end;


{- - - -- - - - Loading FPGA 2 - -- - - - -}

for looptime := 1 to 250000 do
     begin
       waittime := waittime + 1;
     end;

if TestId = 9 then
   begin
     WritenByte := 0;  {All 6 Testers FPGA's started}
     TempCheck := 0;
   end
 else
   begin
     WritenByte := TestId;  {Specific Tester's  FPGA}
     TempCheck := TestId;
   end;
 WriteByte(Sender);
 WritenByte := 2;    {Command}
 WriteByte(Sender);
 WriteComm(hComm, @Buff2, 3854);



for FailCnt := 1 to 100 do
   begin
    GetCommError(hComm,Stat);
     if stat.cbOutQue <> 0 then
       begin
         for looptime := 1 to 19000 do
           begin
             waittime := waittime + 1;
           end;
        end;
     end;

for looptime := 1 to 250000 do
     begin
       waittime := waittime + 1;
     end;

{__ - _   - - - - CHECK if Programmmed OK - - - - - - - -}

if TestId = 9 then
   begin
     for LoopCount := 1 to 6 do
        begin
           WritenByte:= LoopCount;
           TempCheck:= LoopCount;
           CheckFPGAProgrammed(Sender);
        end;
   end
 else
   begin
     WritenByte := TestId;  {Specific Tester's  FPGA}
     TempCheck := TestId;
     CheckFPGAProgrammed(Sender);
   end;

if FPGAReload = true then goto RELOAD1;

end;

procedure TMain.CheckFPGAProgrammed(Sender: TObject);
label Proc1End, LoopRead;
begin
 WriteByte(Sender);   {Address of Tester}
 WritenByte := 6;    {Command}
 WriteByte(Sender);
 CheckSum := 6 + TempCheck;
 WritenByte := CheckSum;      {CheckSum}
 WriteByte(Sender);

for FailCnt := 1 to 200 do
   begin
    GetCommError(hComm,Stat);
     if stat.cbOutque <> 0 then
       begin
         for looptime := 1 to 39000 do
           begin
             waittime := waittime + 1;
           end;
        end;
    end;

for FailCnt := 1 to 200 do
   begin
    GetCommError(hComm,Stat);
     if stat.cbInque <> 4 then
       begin
         for looptime := 1 to 39000 do
           begin
             waittime := waittime + 1;
           end;
        end;
    end;

if FailCnt > 200 then
 begin
  if MessageDlg('Tester ' + inttostr(TempCheck) + ' is not responding' +
                ' to the Status check for Programmed ok -  RELOAD AGAIN ?',
                  mtInformation, [mbYes, mbNo], 0) = mrYes then
                     begin
                      FPGAReload := true;
                      goto Proc1End;
                     end;
   end;
 buf := @readbuf;
 ReadComm(hComm,Buf,Size);
 Addr := Readbuf;
{Command Responded to}
  buf := @readbuf;
  ReadComm(hComm,Buf,Size);
  Command := ReadBuf;
{Data Byte}
  buf := @readbuf;
  ReadComm(hComm,Buf,Size);
  DataLine := ReadBuf;
{Checksum}
  buf := @readbuf;
  ReadComm(hComm,Buf,Size);
  CheckSum := ReadBuf;

if Checksum <> Addr + DataLine + Command then
  begin
   if MessageDlg(' CheckSum on Tester ' + inttostr(TempCheck) +  ' failed ' +
                 ' while confirming FPGA Programmed ok failed , RELOAD AGAIN ?',
                  mtInformation, [mbYes, mbNo], 0) = mrYes then
                     begin
                        FPGAReload := true;
                        goto Proc1End;
                      end;
  end;

if (DataLine and BinMask[6]) <> 0 then
   begin
   if MessageDlg('Response From FPGA1 - Tester ' + inttostr(TempCheck) +
                 ' -  NOT PROGRAMMED SUCCESSFUlLY, RELOAD AGAIN ?',
                 mtInformation, [mbYes, mbNo], 0) = mrYes then
                   begin
                     FPGAReload := true;
                     goto Proc1End;
                   end;
   end;

if (DataLine and BinMask[7]) <> 0 then
   begin
     if MessageDlg('Response From FPGA2 - Tester ' + inttostr(TempCheck) +
                   ' - NOT PROGRAMMED SUCCESSFUlLY , RELOAD AGAIN ?',
                   mtInformation, [mbYes, mbNo], 0) = mrYes then
                      begin
                        FPGAReload := true;
                        goto Proc1End;
                      end;
     end;
Proc1End:;
end;

Procedure TMain.CheckFPGAReady(Sender: TObject);
label ProcEnd;
begin

for FailCnt := 1 to 200 do
   begin
    GetCommError(hComm,Stat);
     if stat.cbOutQue <> 0 then
       begin
         for looptime := 1 to 39000 do
           begin
             waittime := waittime + 1;
           end;
        end;
    end;

 WriteByte(Sender);
 WritenByte := 6;    {Command}
 WriteByte(Sender);
 CheckSum := 6 + TempCheck;
 WritenByte := CheckSum;      {CheckSum}
 WriteByte(Sender);

for FailCnt := 1 to 200 do
   begin
    GetCommError(hComm,Stat);
     if stat.cbInque <> 4 then
       begin
         for looptime := 1 to 39000 do
           begin
             waittime := waittime + 1;
           end;
        end;
    end;

if FailCnt > 200 then
   begin
   if MessageDlg('Tester ' + inttostr(TempCheck) + ' are not ready to receive' +
                 ' the FPGA configuration file after resetting  - RESET AGAIN ?',
                 mtInformation, [mbYes, mbNo], 0) = mrYes then
                    begin
                      FPGAReset := true;
                      goto ProcEnd;
                    end;
   end;

  buf := @readbuf;
  ReadComm(hComm,Buf,Size);
  Addr := Readbuf;
{Command Responded to}
  buf := @readbuf;
  ReadComm(hComm,Buf,Size);
  Command := ReadBuf;
{Data Byte}
  buf := @readbuf;
  ReadComm(hComm,Buf,Size);
  DataLine := ReadBuf;
{Checksum}
  buf := @readbuf;
  ReadComm(hComm,Buf,Size);
  CheckSum := ReadBuf;

if Checksum <> Addr + Command + DataLine then
  begin
   if MessageDlg(' CheckSum on resetting tester '+ inttostr(TempCheck) +
                 ' Failed - RESET and LOAD AGAIN ?',
                  mtInformation, [mbYes, mbNo], 0) = mrYes then
                     begin
                       FPGAReset := True;
                       goto ProcEnd;
                     end;
  end;

if (DataLine and BinMask[4]) <> 0 then
   begin
   if MessageDlg(' Response From Tester '+ inttostr(TempCheck) +
             ' - FPGA1 NOT READY to Receive CFG file- RESET and LOAD AGAIN ?',
                 mtInformation, [mbYes, mbNo], 0) = mrYes then
                    begin
                      FPGAReset := true;
                      goto ProcEnd;
                    end;

if (DataLine and BinMask[5]) <> 0 then
   begin
   if MessageDlg(' Response From Tester '+ inttostr(TempCheck) +
             ' - FPGA2 NOT READY to Receive CFG file- RESET and LOAD AGAIN ?',
                 mtInformation, [mbYes, mbNo], 0) = mrYes then
                    begin
                      FPGAReset := true;
                      goto ProcEnd;
                    end;

   end;
ProcEnd:
end;
end;

procedure TMain.FormCreate(Sender: TObject);
type F1 = Byte;
var F: file;
    f2: file;
    filename : string;
    LoopCount: Integer;
    RBPch :PChar;
    RBuf: Char;
begin
      main.top := 6;
      main.left := 6;
      BinMask[0] := 1;
      BinMask[1] := 2;
      BinMask[2] := 4;
      BinMask[3] := 8;
      BinMask[4] := 16;
      BinMask[5] := 32;
      BinMask[6] := 64;
      BinMask[7] := 128;
      Initialised[1]:= false;
      Initialised[2]:= false;
      Initialised[3]:= false;
      Initialised[4]:= false;
      Initialised[5]:= false;
      Initialised[6]:= false;
      Response := false;
      FPGAReLoad := false;
      Popstop := false;
      discmd3 := false;
      discmd3c := false;
{Load Configfiles for testers in array}

{FILE 1 - FPGA 1}
      filename := 'Test1.cfg';
      if not FileExists(filename) then
          begin
          ShowMessage(' Config file' + filename + ' does not exist !!');
          exit;
          end;
      LoopCount := 1;
      AssignFile(F, filename);
      FileMode := 0;  { Set file access to read only }
      Reset(F, 1);
      while not Eof(F) do
         begin
           BlockRead(F,Buff1[LoopCount],1);
           Loopcount := loopcount + 1;
         end;
      CloseFile(F);
      CfgLength1 := LoopCount - 1;


{FILE 2 - FPGA 2}

     filename := 'Test2.cfg';
      if not FileExists(filename) then
          begin
          ShowMessage(' Config file' + filename + ' does not exist !!');
          exit;
          end;
      LoopCount := 1;
      AssignFile(F, filename);
      FileMode := 0;  { Set file access to read only }
      Reset(F,1);
      while not Eof(F) do
         begin
           BlockRead(F,Buff2[LoopCount],1);
           Loopcount := loopcount + 1;
         end;
    CloseFile(F);
    CfgLength2 := LoopCount - 1;
end;

procedure TMain.Timer1Timer(Sender: TObject);
begin

FlushComm(hComm,0);
FlushComm(hComm,1);

if TimerCycle = 1 then
      begin
      TimerCycle := 0;
      for loopcount := 1 to 6 do
         begin
          TestId := loopcount;
             if ActiveTester[TestId] = true then
                begin
                  InterfChange(Sender);     {Done}
                  CheckInsError(Sender);    {Done}
                  CheckDtrChange(Sender);   {Martin}
                  ExecCmd4(Sender);         {Done}
                  ExecCmd3Sync(Sender);     {Done}
                  ExecCmd30Status(Sender);  {Done}
                  ElapsTime(Sender);        {Done}
                end;
         end;
      end
  else
     TimerCycle := 1;
      for loopcount := 1 to 6 do
         begin
          TestId := loopcount;
             if ActiveTester[TestId] = true then
                begin
                  ReportErrors(Sender);     {Done}
                end;
         end;
end;

procedure TMain.CheckInsError(Sender: TObject);
begin

FlushComm(hComm,0);
FlushComm(hComm,1);


  if InsertError[TestId] = true then
     begin
        InsertError[TestId] := false;
        WritenByte := TestID;  {Address}
        WriteByte(Sender);
        WritenByte := 4;    {Command}
        WriteByte(Sender);
        WritenByte := 5;    {Latch}
        WriteByte(Sender);
        WritenByte := 16;   {Data}
        WriteByte(Sender);
        CheckSum := TestId + 4 + 5 + 16;
        WritenByte := CheckSum;      {CheckSum}
        WriteByte(Sender);
        for FailCnt := 1 to 200 do
            begin
               GetCommError(hComm,Stat);
                 if stat.cbInque <> 3 then
                    begin
                      for looptime := 1 to 1500 do
                         begin
                            waittime := waittime + 1;
                         end;
                    end
                  else
                     begin
                      FailCnt := 199;
                     end;
            end;
         ReadCmdResponse(Sender);

    end;
end;

procedure TMain.InterfChange(Sender: TObject);
label StopLoop;
begin

FlushComm(hComm,0);
FlushComm(hComm,1);

    if InterfaceChange[TestId] = true then
     begin
        InterfaceChange[TestId] := false;
        WritenByte := TestID;
        WriteByte(Sender);
        WritenByte := 4;    {Command}
        WriteByte(Sender);
        WritenByte := 5;    {Latch}
        WriteByte(Sender);
          if InterfaceType[TestId] = 2 then
           begin
            WritenByte := 0;   {Data}
            WriteByte(Sender);
            CheckSum := TestId + 4 + 5 + 0;
           end
          else  if InterfaceType[TestId] = 3 then
           begin
            WritenByte := 1;   {Data}
            WriteByte(Sender);
            CheckSum := TestId + 4 + 5 + 1;
           end
          else if InterfaceType[TestId] = 1 then
           begin
            WritenByte := 2;   {Data}
            WriteByte(Sender);
            CheckSum := TestId + 4 + 5 + 2;
           end;
        WritenByte := CheckSum;      {CheckSum}
        WriteByte(Sender);
        for FailCnt := 1 to 100 do
           begin
            GetCommError(hComm,Stat);
            if stat.cbInque <> 3 then
                begin
                  for looptime := 1 to 1000 do
                      begin
                        waittime := waittime + 1;
                      end;
                end
             else
               begin
                  goto StopLoop;
               end;
          end;
StopLoop:

        ReadCmdResponse(Sender);

     end;

end;


procedure TMain.CheckDtrChange(Sender: TObject);
begin
 { if DtrRtsSet[TestId] = true then
     begin
{       DtrRtsSet[TestId] := false;
{         if GetCommState(hComm,DCB) <> 0 then
           begin
              ShowMessage('hjdejkweq');
              Exit;
           end;
{       SendString[1] := TestId;  {Tester Id}
{       SendString[2] := 4;       {Command}
{       SendString[3] := 5;       {Latch}
{       CheckSumInt := TestId + 4 + 5 + SendString[4];
{       SendString[4] := CheckSumInt;      {CheckSum}

{     end; }
end;

procedure TMain.ExecCmd4(Sender: TObject);
label stoploop;
begin
{ =======  Setup / Change for SYNC, Clk Divider & TestPattern ===============}

if TestPatChange[TestId] = false then exit;

FlushComm(hComm,0);
FlushComm(hComm,1);


TestPatChange[TestId] := false;
WritenByte := TestID;  {Address}
WriteByte(Sender);
WritenByte := 4;       {Command}
WriteByte(Sender);
WritenByte := 0;       {Latch}
WriteByte(Sender);

if TestPattern[TestId] = 1 then
  begin
    WritenByte := 0;     {Data}
    WriteByte(Sender);
    CheckSum := TestId + 4 + 0 + 0;
    WriteByte(Sender);
  end
else if TestPattern[TestId] = 2 then
  begin
    WritenByte := 4;     {Data}
    WriteByte(Sender);
    CheckSum := TestId + 4 + 0 + 4;
    WriteByte(Sender);
  end
else if TestPattern[TestId] = 3 then
  begin
    WritenByte := 6;     {Data}
    WriteByte(Sender);
    CheckSum := TestId + 4 + 0 + 6;
    WriteByte(Sender);
  end
else if TestPattern[TestId] = 4 then
  begin
    WritenByte := 2;     {Data}
    WriteByte(Sender);
    CheckSum := TestId + 4 + 0 + 2;
    WriteByte(Sender);
  end
else
    begin
    WritenByte := 0;     {Defaults to 511}
    WriteByte(Sender);
    CheckSum := TestId + 4 + 0 + 0;
    WriteByte(Sender);
    end;

for FailCnt := 1 to 200 do
    begin
      GetCommError(hComm,Stat);
      if stat.cbInque <> 3 then
         begin
           for looptime := 1 to 9000 do
              begin
                waittime := waittime + 1;
              end;
          end
      else
         begin
           goto stoploop;
         end;
   end;

StopLoop:

ReadCmdResponse(Sender);

         {Check Reponse for Command 4 Write to Latch}

end;


procedure TMain.ExecCmd3Sync(Sender: TObject);   {Getting SYNC Status}
var buf: pchar;
    size: smallint;
    FailCnt: smallint;
    ReadByte: byte;
label stopSADRloop, StopSCMDLoop, StopSDATALoop, StopSCHECKLoop, SProcEnd;
begin
{ ================ Send SYNC Latch 1 Request ==============================}


FlushComm(hComm,0);
FlushComm(hComm,1);
   WritenByte := TestID;
   WriteByte(Sender);
   WritenByte := 3;    {Command}
   WriteByte(Sender);
   WritenByte := 1;    {LATCH}
   WriteByte(Sender);
   CheckSum := TestId + 3 + 1;
   WritenByte := CheckSum;      {CheckSum}
   WriteByte(Sender);

for FailCnt := 1 to 200 do
    begin
      GetCommError(hComm,Stat);
      if stat.cbInque <> 4 then
          begin
           for looptime := 1 to 500 do
             begin
                waittime := waittime + 1;
             end;
          end
      else
         begin
          goto stopsDataloop
         end;
    end;

stopsDataloop:
{=============== Get SYNC RESPONSE FROM TESTER =======================}

ReadCmdResponse(Sender);

If CheckSum <> Addr + Command + DataLine then
    Begin
      IF POPSTOP = TRUE THEN
       begin
         ShowMessage('Checksum Failed while Reading SYNC Response');
         Popstop := false;
         Exit;
       end;
    end;

{Address, Data and CheckSum OK - check response and update Window }

if (DataLine and BinMask[0]) <> 0  then
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

SProcEnd:
end;


{ ==================  Send command to setup Status  ===========================}
procedure TMain.ExecCmd30Status(Sender: TObject);
label  StopDATALoop, StopCHECKLoop, EndProc;
begin
FlushComm(hComm,0);
FlushComm(hComm,1);

WritenByte := TestID;
WriteByte(Sender);
WritenByte := 3;    {Command}
WriteByte(Sender);
WritenByte := 1;    {LATCH}
WriteByte(Sender);
CheckSum := TestId + 3 + 1;
WritenByte := CheckSum;      {CheckSum}
WriteByte(Sender);

for FailCnt := 1 to 200 do
    begin
      GetCommError(hComm,Stat);
      if stat.cbInque <> 4 then
          begin
           for looptime := 1 to 2900 do
              begin
                waittime := waittime + 1;
              end;
          end
      else
         begin
           goto stopDataloop
         end;
    end;

stopDataloop:

if discmd3 = false then
  begin
   discmd3 := true;
   if failCnt > 199 then
     begin
       showmessage(' not responding to cmd 3 --- status  ');
     end;
  end;

ReadCmdResponse(Sender);

{If Command <> 3 then goto EndProc;}
if discmd3C = false then
   begin
     discmd3C := true;
     If CheckSum <> Addr + Command + DataLine then
       begin
         ShowMessage('Checksum Failed while command 3  Reading Response');
       end;
   end;

For LoopCount := 0 to 7 do
        begin
          StatusInd[LoopCount] := false;
        end;

if (DataLine and BinMask[0]) <> 0 then
     StatusInd[0] := true;
if (DataLine and BinMask[1]) <> 0 then
     StatusInd[1] := true;
if (DataLine and BinMask[2]) <> 0 then
     StatusInd[2] := true;
if (DataLine and BinMask[3]) <> 0 then
     StatusInd[3] := true;
if (DataLine and BinMask[4]) <> 0 then
     StatusInd[4] := true;
if (DataLine and BinMask[5]) <> 0 then
     StatusInd[5] := true;
if (DataLine and BinMask[6]) <> 0 then
     StatusInd[6] := true;
if (DataLine and BinMask[7]) <> 0 then
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

endproc:

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
procedure TMain.ReportErrors(Sender: TObject);
var RecErrInt: integer;
label StopDataLoop;
begin
   WritenByte := TestId;
   WriteByte(Sender);
   WritenByte := 5;    {Command}
   WriteByte(Sender);
   CheckSum := TestId + 5;
   WritenByte := CheckSum;      {CheckSum}
   WriteByte(Sender);

for FailCnt := 1 to 200 do
  begin
    GetCommError(hComm,Stat);
    if stat.cbInque <> 4 then
      begin
      for looptime := 1 to 500 do
        begin
          waittime := waittime + 1;
        end;
      end
     else
        begin
          goto stopdataloop;
        end;
  end;

StopDataLoop:

{Tester Address}
    buf := @readbuf;
    ReadComm(hComm,Buf,Size);
    Addr := Readbuf;

 {Command Responded to}
    buf := @readbuf;
    ReadComm(hComm,Buf,Size);
    Command := ReadBuf;
          {Check if Command = 5}

 {Error Count #1 returned }
    buf := @readbuf;
    ReadComm(hComm,Buf,Size);
    ErrorCount1 := ReadBuf;

 {Error Count #2 returned }
    buf := @readbuf;
    ReadComm(hComm,Buf,Size);
    ErrorCount2 := ReadBuf;


 {Checksum}
    buf := @readbuf;
    ReadComm(hComm,Buf,Size);
    CheckSum := ReadBuf;

{Check if Address is same than TestId}

 if CheckSum <> Addr + Command + ErrorCount1 + ErrorCount2 then
     begin
       Response := false;
     end;

 RecErrInt:= ErrorCount1;
 RecErrInt := RecErrInt shl RecErrInt;
 RecErrInt := RecErrInt + ErrorCount2;


If addr = 1 then
        begin
           ErrCount[1] := ErrCount[1] + RecErrInt;
           TesWin1.BitErrors.text := inttostr(ErrCount[1]);
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


procedure TMain.ResetCycle(Sender: TObject);
begin
     if  TestId = 1 then
        begin
           ResetWin1(Sender);
        end
     else
      if  TestId = 2 then
        begin
           ResetWin2(Sender);
        end
     else
     if  TestId = 3 then
        begin
           ResetWin3(Sender);
        end
     else
     if  TestId = 4 then
        begin
           ResetWin4(Sender);
        end
     else
     if  TestId = 5 then
        begin
           ResetWin5(Sender);
        end
     else
     if  TestId = 6 then
        begin
           ResetWin6(Sender);
        end;
end;

procedure TMain.ResetWin1(Sender: TObject);
begin
  if InterfaceType[TestId] = 2 then
      begin
            TesWin1.IntInd8.color := clwhite;
            TesWin1.IntInd7.color := clwhite;
            TesWin1.IntInd9.color := clwhite;
            TesWin1.IntInd0.color := clwhite;
            TesWin1.IntInd4.color := clwhite;
            TesWin1.IntInd5.color := clwhite;
            TesWin1.IntInd6.color := clwhite;
            TesWin1.IntInd12.color := clwhite;
      end
  else
    if InterfaceType[TestId] = 3 then
      begin
            TesWin1.IntInd8.color := clwhite;
            TesWin1.IntInd7.color := clwhite;
            TesWin1.IntInd9.color := clwhite;
            TesWin1.IntInd0.color := clwhite;
            TesWin1.IntInd4.color := clwhite;
            TesWin1.IntInd5.color := clwhite;
            TesWin1.IntInd6.color := clwhite;
            TesWin1.IntInd12.color := clwhite;
      end
  else
    if InterfaceType[TestId] = 1 then
      begin
           TesWin1.IntInd6.color := clwhite;
           TesWin1.IntInd7.color := clwhite;
           TesWin1.IntInd9.color := clwhite;
           TesWin1.IntInd0.color := clwhite;
           TesWin1.IntInd4.color := clwhite;
      end;
end;

procedure TMain.ResetWin2(Sender: TObject);
begin
  if InterfaceType[TestId] = 2 then
      begin
            TesWin2.IntInd8.color := clwhite;
            TesWin2.IntInd7.color := clwhite;
            TesWin2.IntInd9.color := clwhite;
            TesWin2.IntInd0.color := clwhite;
            TesWin2.IntInd4.color := clwhite;
            TesWin2.IntInd5.color := clwhite;
            TesWin2.IntInd6.color := clwhite;
            TesWin2.IntInd12.color := clwhite;
      end
  else
    if InterfaceType[TestId] = 3 then
      begin
            TesWin2.IntInd8.color := clwhite;
            TesWin2.IntInd7.color := clwhite;
            TesWin2.IntInd9.color := clwhite;
            TesWin2.IntInd0.color := clwhite;
            TesWin2.IntInd4.color := clwhite;
            TesWin2.IntInd5.color := clwhite;
            TesWin2.IntInd6.color := clwhite;
            TesWin2.IntInd12.color := clwhite;
      end
  else
    if InterfaceType[TestId] = 1 then
      begin
           TesWin2.IntInd6.color := clwhite;
           TesWin2.IntInd7.color := clwhite;
           TesWin2.IntInd9.color := clwhite;
           TesWin2.IntInd0.color := clwhite;
           TesWin2.IntInd4.color := clwhite;
      end;
end;

procedure TMain.ResetWin3(Sender: TObject);

begin
  if InterfaceType[TestId] = 2 then
      begin
            TesWin3.IntInd8.color := clwhite;
            TesWin3.IntInd7.color := clwhite;
            TesWin3.IntInd9.color := clwhite;
            TesWin3.IntInd0.color := clwhite;
            TesWin3.IntInd4.color := clwhite;
            TesWin3.IntInd5.color := clwhite;
            TesWin3.IntInd6.color := clwhite;
            TesWin3.IntInd12.color := clwhite;
      end
  else
    if InterfaceType[TestId] = 3 then
      begin
            TesWin3.IntInd8.color := clwhite;
            TesWin3.IntInd7.color := clwhite;
            TesWin3.IntInd9.color := clwhite;
            TesWin3.IntInd0.color := clwhite;
            TesWin3.IntInd4.color := clwhite;
            TesWin3.IntInd5.color := clwhite;
            TesWin3.IntInd6.color := clwhite;
            TesWin3.IntInd12.color := clwhite;
      end
  else
    if InterfaceType[TestId] = 1 then
      begin
           TesWin3.IntInd6.color := clwhite;
           TesWin3.IntInd7.color := clwhite;
           TesWin3.IntInd9.color := clwhite;
           TesWin3.IntInd0.color := clwhite;
           TesWin3.IntInd4.color := clwhite;
      end;
end;

procedure TMain.ResetWin4(Sender: TObject);

begin
  if InterfaceType[TestId] = 2 then
      begin
            TesWin4.IntInd8.color := clwhite;
            TesWin4.IntInd7.color := clwhite;
            TesWin4.IntInd9.color := clwhite;
            TesWin4.IntInd0.color := clwhite;
            TesWin4.IntInd4.color := clwhite;
            TesWin4.IntInd5.color := clwhite;
            TesWin4.IntInd6.color := clwhite;
            TesWin4.IntInd12.color := clwhite;
      end
  else
    if InterfaceType[TestId] = 3 then
      begin
            TesWin4.IntInd8.color := clwhite;
            TesWin4.IntInd7.color := clwhite;
            TesWin4.IntInd9.color := clwhite;
            TesWin4.IntInd0.color := clwhite;
            TesWin4.IntInd4.color := clwhite;
            TesWin4.IntInd5.color := clwhite;
            TesWin4.IntInd6.color := clwhite;
            TesWin4.IntInd12.color := clwhite;
      end
  else
    if InterfaceType[TestId] = 1 then
      begin
           TesWin4.IntInd6.color := clwhite;
           TesWin4.IntInd7.color := clwhite;
           TesWin4.IntInd9.color := clwhite;
           TesWin4.IntInd0.color := clwhite;
           TesWin4.IntInd4.color := clwhite;
      end;
end;

procedure TMain.ResetWin5(Sender: TObject);

begin
  if InterfaceType[TestId] = 2 then
      begin
            TesWin5.IntInd8.color := clwhite;
            TesWin5.IntInd7.color := clwhite;
            TesWin5.IntInd9.color := clwhite;
            TesWin5.IntInd0.color := clwhite;
            TesWin5.IntInd4.color := clwhite;
            TesWin5.IntInd5.color := clwhite;
            TesWin5.IntInd6.color := clwhite;
            TesWin5.IntInd12.color := clwhite;
      end
  else
    if InterfaceType[TestId] = 3 then
      begin
            TesWin5.IntInd8.color := clwhite;
            TesWin5.IntInd7.color := clwhite;
            TesWin5.IntInd9.color := clwhite;
            TesWin5.IntInd0.color := clwhite;
            TesWin5.IntInd4.color := clwhite;
            TesWin5.IntInd5.color := clwhite;
            TesWin5.IntInd6.color := clwhite;
            TesWin5.IntInd12.color := clwhite;
      end
  else
    if InterfaceType[TestId] = 1 then
      begin
           TesWin5.IntInd6.color := clwhite;
           TesWin5.IntInd7.color := clwhite;
           TesWin5.IntInd9.color := clwhite;
           TesWin5.IntInd0.color := clwhite;
           TesWin5.IntInd4.color := clwhite;
      end;
end;

procedure TMain.ResetWin6(Sender: TObject);

begin
  if InterfaceType[TestId] = 2 then
      begin
            TesWin6.IntInd8.color := clwhite;
            TesWin6.IntInd7.color := clwhite;
            TesWin6.IntInd9.color := clwhite;
            TesWin6.IntInd0.color := clwhite;
            TesWin6.IntInd4.color := clwhite;
            TesWin6.IntInd5.color := clwhite;
            TesWin6.IntInd6.color := clwhite;
            TesWin6.IntInd12.color := clwhite;
      end
  else
    if InterfaceType[TestId] = 3 then
      begin
            TesWin6.IntInd8.color := clwhite;
            TesWin6.IntInd7.color := clwhite;
            TesWin6.IntInd9.color := clwhite;
            TesWin6.IntInd0.color := clwhite;
            TesWin6.IntInd4.color := clwhite;
            TesWin6.IntInd5.color := clwhite;
            TesWin6.IntInd6.color := clwhite;
            TesWin6.IntInd12.color := clwhite;
      end
  else
    if InterfaceType[TestId] = 1 then
      begin
           TesWin6.IntInd6.color := clwhite;
           TesWin6.IntInd7.color := clwhite;
           TesWin6.IntInd9.color := clwhite;
           TesWin6.IntInd0.color := clwhite;
           TesWin6.IntInd4.color := clwhite;
      end;
end;

procedure TMain.Com11Click(Sender: TObject);
begin
   ComClear(Sender);
   CommStr :='COM1:';
   Commstr1 := 'COM1';
   ComSetup(Sender);
   Com11.Checked := true;
   Com21.Checked := false;
   Com31.Checked := false;
   Setup1.Visible := true;
end;

procedure TMain.Com21Click(Sender: TObject);
begin
   ComClear(Sender);
   CommStr :='COM2:';
   Commstr1 := 'COM2';
   ComSetup(Sender);
   Com21.Checked := true;
   Com11.Checked := false;
   Com31.Checked := false;
   Setup1.Visible := true;
end;

procedure TMain.Com31Click(Sender: TObject);
begin
   ComClear(Sender);
   CommStr :='COM3:';
   Commstr1 := 'COM3';
   ComSetup(Sender);
   Com31.Checked := true;
   Com11.Checked := false;
   Com21.Checked := false;
   Setup1.Visible := true;
end;

procedure TMain.ComClear(Sender: TObject);
begin
   CloseComm(hComm);
end;

procedure TMain.ComSetup(Sender: TObject);
var Def: string;
    pc : PChar;
    FlPc: Pchar;
    FlagSets: word;
begin
  ReadBufferSize:= 10;
  WriteBufferSize:= 3900;
  hComm:=OpenComm(CommStr,ReadBufferSize,WriteBufferSize);
  EscapeCommFunction(hComm, 1);
  { if n192001.Checked = true then begin DCB.BaudRate:=19200; end
  else if  n192001.Checked = true then begin DCB.BaudRate:=38400; end
  else if   n192001.Checked = true then begin DCB.BaudRate:=56000; end;}
  {DCB.Parity:= 0;
  DCB.BaudRate:=38400;
  DCB.ByteSize:=8;
  DCB.StopBits:= 0;
  DCB.Id:=hcomm; }
                                  {  1,1,0,0,0,0,0,1,0,0,0,0,0,0,0,0}
  {FlagSets := 49408;            { 1 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 + Flpc^;}
  {FlPc := @FlagSets;
  Def := Commstr1 + ',19200,8,0,1,,,,' + ;
  pc := @Def;

 if BuildCommDCB(@Def,DCB) <> 0 then
    begin
      Showmessage('DCB Build Failed');
      exit;
    end;  }

  DCB.Parity:= 0;
  DCB.BaudRate:=19200;
  DCB.ByteSize:=8;
  DCB.StopBits:= 0;
  DCB.Id:=hcomm;
  SetCommState(DCB);
  if GetCommState(hComm,DCB) <> 0 then
   begin
    showMessage('-Setting Failed -' +
               (' baudrate :' + inttostr(DCB.Baudrate) +
               (' bytesize : 8'  + '  parity : None' +
               (' hcomm :' + inttostr(DCB.id)))));
    EscapeCommFunction(hComm, 1);
    GetCommState(hComm,DCB);
    MessageDlg(' Check the Hardware and Check that no other Applications' +
    ' is using the selected Port', mtInformation, [mbOk], 0);
    exit;
    end;
GetCommState(hComm,DCB);
   begin;
    showMessage('-- Setting ----- ' +
               (' baudrate :' + inttostr(DCB.Baudrate) +
               (' bytesize : 8'  + '  parity : None' +
               (' hcomm :' + inttostr(DCB.id)))));
EscapeCommFunction(hComm, 0);
EscapeCommFunction(hComm, 1);
EscapeCommFunction(hComm, 2);
    end;
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

procedure TMain.WriteByte(Sender: TObject);
label WriteLoop;
begin
    Pch1:= @WritenByte;
WriteLoop:
    if TransmitCommChar(hComm, Pch1^) <> 0 then
       begin
          goto WriteLoop;
       end;
end;

procedure TMain.ReadCmdResponse(Sender: TObject);
{ ================== Command Response ==============================}
 begin

 {Tester Address}
    buf := @readbuf;
    ReadComm(hComm,Buf,Size);
    Addr := Readbuf;

 {Command Responded to}
    buf := @readbuf;
    ReadComm(hComm,Buf,Size);
    Command := ReadBuf;

 {Data Byte}
 if Stat.cbInQue = 4 then
    begin
      buf := @readbuf;
      ReadComm(hComm,Buf,Size);
      DataLine := ReadBuf;
    end;

 {Checksum}
    buf := @readbuf;
    ReadComm(hComm,Buf,Size);
    CheckSum := ReadBuf;

FlushComm(hComm,0);
FlushComm(hComm,1);

end;

end.

