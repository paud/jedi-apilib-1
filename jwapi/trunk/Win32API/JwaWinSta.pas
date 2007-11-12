{******************************************************************}
{ This Unit provides Delphi translations of some functions from    }
{ WinSta.dll. The functions are not documented by Microsoft and    }
{ were tested only with Windows 2003 standard. Functions were not  }
{ tested with Windows 2000, but are expected to work.              }
{                                                                  }
{ Author: Remko Weijnen (r dot weijnen at gmail dot com)           }
{ Version: 0.3                                                     }
{ Date: 03-01-2007                                                 }
{                                                                  }
{ The contents of this file are subject to                         }
{ the Mozilla Public License Version 1.1 (the "License"); you may  }
{ not use this file except in compliance with the License. You may }
{ obtain a copy of the License at                                  }
{ http://www.mozilla.org/MPL/MPL-1.1.html                          }
{                                                                  }
{ Software distributed under the License is distributed on an      }
{ "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or   }
{ implied. See the License for the specific language governing     }
{ rights and limitations under the License.                        }
{******************************************************************}

// $Id: JwaWinSta.pas,v 1.4 2007/09/05 15:46:45 marquardt Exp $

{$IFNDEF JWA_OMIT_SECTIONS}

unit JwaWinSta;

interface

uses
  SysUtils, DateUtils,
  JwaWinType, JwaWinBase, JwaWinDllNames;

{$ENDIF JWA_OMIT_SECTIONS}
{$I jediapilib.inc}

{$IFNDEF JWA_IMPLEMENTATIONSECTION}

type
  {$IFNDEF JWA_INCLUDEMODE}
  HANDLE = THandle;
  PVOID = Pointer;
  {$ENDIF JWA_INCLUDEMODE}

  _WINSTATIONQUERYINFORMATIONW = record
    State: DWORD;
    WinStationName: array[0..10] of WideChar;
    Unknown1: array[0..10] of byte;
    Unknown3: array[0..10] of WideChar;
    Unknown2: array[0..8] of byte;
    SessionId: DWORD;
    Reserved2: array[0..3] of byte;
    ConnectTime: FILETIME;
    DisconnectTime: FILETIME;
    LastInputTime: FILETIME;
    LogonTime: FILETIME;
    Unknown4: array[0..11] of byte;
    OutgoingFrames: DWORD;
    OutgoingBytes: DWORD;
    OutgoingCompressBytes: DWORD;
    Unknown5: array[0..435] of byte;
    IncomingCompressedBytes: DWORD;
    Unknown6: array[0..7] of byte;
    IncomingFrames: DWORD;
    IncomingBytes: DWORD;
    Unknown7: array[0..3] of byte;
    Reserved3: array[0..528] of byte;
    Domain: array[0..17] of WideChar;
    Username: array[0..22] of WideChar;
    CurrentTime: FILETIME;
  end;


{***********************************************************}
{ WinStationShadow: Shadow another user's session           }
{ hServer   : Handle to Terminal Server                     }
{             Use WTSOpenServer to obtain or pass           }
{             SERVERNAME_CURRENT                            }
{                                                           }
{ pServerName: ServerName (or IP), can be nil or empty      }
{              string for local server                      }
{                                                           }
{ SessionID : The session you want to shadow                }
{                                                           }
{ Hotkey    : The hotkey to end the remote control.         }
{             must be a Virtual-Key Code.                   }
{             Supply VK_MULTIPLY for the default (*)        }
{                                                           }
{ HKModifier: Key to press in combination with Hotkey,      }
{             also a Virtual-Key code. Supply MOD_CONTROL   }
{             for the default (CTRL)                        }
{                                                           }
{ v0.2:                                                     }
{ Changed param2 Unknown: DWORD to pServerName: PWideChar   }
{***********************************************************}
function WinStationShadow(hServer: Handle; pServerName: PWideChar; SessionID: DWORD; HotKey: DWORD;
  HKModifier: DWORD): Boolean; stdcall;

{***********************************************************}
{ WinStationShadowStop: Not needed, is called for you when  }
{ pressing the hotkey supplied with WinStationShadow        }
{ v0.2:                                                     }
{ Added param 3, Unknown: Integer                           }
{                (note: possibly pServerName: PWideChar;    }
{ Not tested!                                               }
{***********************************************************}
function WinStationShadowStop(hServer: Handle; SessionID: DWORD; Unknown: Integer): Boolean; stdcall;

{***********************************************************}
{ WinStationConnect: Connect to a session                   }
{ Target session will be disconnected. When connecting to   }
{ another users session, you have to provide password       }
{ Password must not be nil, empty string '' is allowed to   }
{ connect to owned session                                  }
{ hServer: Handle to Terminal Server                        }
{          Use WTSOpenServer to obtain or pass              }
{          SERVERNAME_CURRENT                               }
{                                                           }
{ SessionID: The session you want to connect to             }
{                                                           }
{ TargetSessionID: The Session which is connected to the    }
{                  SessionID (LOGINID_CURRENT)              }
{                                                           }
{ pPassword: Password for the disconnected session, it's    }
{            the Windows password for the user that owns    }
{            the session. Supply PWideChar('') for no       }
{            password, nil is invalid.                      }
{ bWait: Boolean, wait until the connect has completed      }
{                                                           }
{ v0.3:                                                     }
{ Changed to stdcall, changed Unknown to boolean bWait      }
{ changed name ActiveSessionID to TargetSessionID           }
{ Function tested and working on Windows 2003               }
{***********************************************************}
function WinStationConnectW(hServer: Handle; SessionID: DWORD; TargetSessionID: DWORD; pPassword: PWideChar;
  bWait: Boolean): Boolean; stdcall;

function WinStationDisconnect(hServer: THandle; SessionId: DWORD;
  bWait: BOOLEAN): BOOLEAN; stdcall;

function WinStationGetProcessSid(hServer: Handle; dwPID: DWORD;
  ProcessStartTime: FILETIME; pProcessUserSid: PSID; var dwSidSize: DWORD): BOOLEAN; stdcall;

procedure CachedGetUserFromSid(pSid: PSID; pUserName: PWideChar;
  var cbUserName: DWORD); stdcall;

function WinStationTerminateProcess(hServer: Handle; dwPID: DWORD; dwExitCode: DWORD): BOOL; stdcall;
{***********************************************************}
{ WinStationTerminateProcess: Terminate a process           }
{                                                           }
{ hServer: Handle to Terminal Server                        }
{          Use WTSOpenServer to obtain handle or pass       }
{          SERVERNAME_CURRENT                               }
{                                                           }
{ dwPid: Pid of the process you want to terminate           }
{                                                           }
{ dwExitCode: Exitcode, usually 0                           }
{***********************************************************}


{***********************************************************}
{ WinStationQueryInformation: Query Terminal Sessions Info  }
{ When using WTSAPI function, this function is called       }
{ supply WinStationInformationClass 8 to retrieve Idle Time }
{ and logon time, see helper function GetWTSIdleTime        }
{                                                           }
{ hServer: Handle to Terminal Server                        }
{          Use WTSOpenServer to obtain handle or pass       }
{          SERVERNAME_CURRENT                               }
{                                                           }
{ SessionID: The session you want query                     }
{***********************************************************}
function WinStationQueryInformationW(hServer: HANDLE; SessionId: DWORD;
  WinStationInformationClass: Cardinal; pWinStationInformation: PVOID;
  WinStationInformationLength: DWORD; var pReturnLength: DWORD):
  Boolean; stdcall;

function GetWTSLogonIdleTime(hServer: Handle; SessionID: DWORD;
  var sLogonTime: string; var sIdleTime: string): Boolean;

function FileTime2DateTime(FileTime: FileTime): TDateTime;

{$IFNDEF JWA_INCLUDEMODE}
const
  SERVERNAME_CURRENT  = HANDLE(0);
  LOGONID_CURRENT = DWORD(-1);
{$ENDIF JWA_INCLUDEMODE}

{$ENDIF JWA_IMPLEMENTATIONSECTION}

{$IFNDEF JWA_OMIT_SECTIONS}
implementation
{$ENDIF JWA_OMIT_SECTIONS}

{$IFNDEF JWA_INTERFACESECTION}

{$IFNDEF JWA_INCLUDEMODE}
const
  winstaDLL = 'winsta.dll';
  utildll = 'utildll.dll';
{$ENDIF JWA_INCLUDEMODE}

{$IFNDEF DYNAMIC_LINK}     
function WinStationShadow; external winstaDLL name 'WinStationShadow';

function WinStationShadowStop; external winstaDLL name 'WinStationShadowStop';

function WinStationDisconnect; external winstaDLL name 'WinStationDisconnect';

function WinStationConnectW; external winstaDLL name 'WinStationConnectW';

function WinStationGetProcessSid; external winstaDLL name 'WinStationGetProcessSid';

procedure CachedGetUserFromSid; external utildll name 'CachedGetUserFromSid';

function WinStationTerminateProcess; external winstaDLL name 'WinStationTerminateProcess';

function WinStationQueryInformationW; external winstaDLL name 'WinStationQueryInformationW';
{$ELSE}

var
  __WinStationShadow: Pointer;

function WinStationShadow;
begin
  GetProcedureAddress(__WinStationShadow, winstaDLL, 'WinStationShadow');
  asm
        MOV     ESP, EBP
        POP     EBP
        JMP     [__WinStationShadow]
  end;
end;

var
  __WinStationShadowStop : Pointer;
  
function WinStationShadowStop;
begin
  GetProcedureAddress(__WinStationShadowStop, winstaDLL, 'WinStationShadowStop');
  asm
        MOV     ESP, EBP
        POP     EBP
        JMP     [__WinStationShadowStop]
  end;
end;

var
  __WinStationDisconnect: Pointer;
  
function WinStationDisconnect;
begin
  GetProcedureAddress(__WinStationDisconnect, winstaDLL, 'WinStationDisconnect');
  asm
        MOV     ESP, EBP
        POP     EBP
        JMP     [__WinStationDisconnect]
  end;
end;


var
  __WinStationConnectW: Pointer;
  
function WinStationConnectW;
begin
  GetProcedureAddress(__WinStationConnectW, winstaDLL, 'WinStationConnectW');
  asm
        MOV     ESP, EBP
        POP     EBP
        JMP     [__WinStationConnectW]
  end;
end;


var
  __WinStationGetProcessSid: Pointer;
  
function WinStationGetProcessSid;
begin
  GetProcedureAddress(__WinStationGetProcessSid, winstaDLL, 'WinStationGetProcessSid');
  asm
        MOV     ESP, EBP
        POP     EBP
        JMP     [__WinStationGetProcessSid]
  end;
end;

var
  __CachedGetUserFromSid: Pointer;
  
procedure CachedGetUserFromSid;
begin
  GetProcedureAddress(__CachedGetUserFromSid, winstaDLL, 'CachedGetUserFromSid');
  asm
        MOV     ESP, EBP
        POP     EBP
        JMP     [__CachedGetUserFromSid]
  end;
end;

var
  __WinStationTerminateProcess: Pointer;
  
function WinStationTerminateProcess;
begin
  GetProcedureAddress(__WinStationTerminateProcess, winstaDLL, 'WinStationTerminateProcess');
  asm
        MOV     ESP, EBP
        POP     EBP
        JMP     [__WinStationTerminateProcess]
  end;
end;


var
  __WinStationQueryInformationW : Pointer;
  
function WinStationQueryInformationW;
begin
  GetProcedureAddress(__WinStationQueryInformationW, winstaDLL, 'WinStationQueryInformationW');
  asm
        MOV     ESP, EBP
        POP     EBP
        JMP     [__WinStationQueryInformationW]
  end;
end;

{$ENDIF DYNAMIC_LINK}

function FileTime2DateTime(FileTime: FileTime): TDateTime;
var
  LocalFileTime: TFileTime;
  SystemTime: TSystemTime;
begin
  FileTimeToLocalFileTime(FileTime, LocalFileTime);
  FileTimeToSystemTime(LocalFileTime, SystemTime);
  Result := SystemTimeToDateTime(SystemTime);
end;

function GetWTSLogonIdleTime(hServer: HANDLE; SessionID: DWORD;
  var sLogonTime: string; var sIdleTime: string): Boolean;
var
  uReturnLength: DWORD;
  Info: _WINSTATIONQUERYINFORMATIONW;
  CurrentTime: TDateTime;
  LastInputTime: TDateTime;
  IdleTime: TDateTime;
  LogonTime: TDateTime;
  Days, Hours, Minutes: Word;
  {$IFDEF COMPILER7_UP}
  FS: TFormatSettings;
  {$ENDIF COMPILER7_UP}
begin
  {$IFDEF COMPILER7_UP}
  GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, FS);
  {$ENDIF COMPILER7_UP}
  uReturnLength := 0;
  try
    Result := WinStationQueryInformationW(hServer, SessionID, 8, @Info, SizeOf(Info), uReturnLength);
    if Result then
    begin
      LogonTime := FileTime2DateTime(Info.LogonTime);
      if YearOf(LogonTime) = 1601 then
        sLogonTime := ''
      else
        {$IFDEF COMPILER7_UP}
        sLogonTime := DateTimeToStr(LogonTime, FS);
        {$ELSE}
        sLogonTime := DateTimeToStr(LogonTime);
        {$ENDIF COMPILER7_UP}
      { from Usenet post by Chuck Chopp
        http://groups.google.com/group/microsoft.public.win32.programmer.kernel/browse_thread/thread/c6dd86e7df6d26e4/3cf53e12a3246e25?lnk=st&q=WinStationQueryInformationa+group:microsoft.public.*&rnum=1&hl=en#3cf53e12a3246e25
        2)  The system console session cannot go into an idle/disconnected state.
            As such, the LastInputTime value will always math CurrentTime for the
            console session.
        3)  The LastInputTime value will be zero if the session has gone
            disconnected.  In that case, use the DisconnectTime value in place of
            LastInputTime when calculating the current idle time for a disconnected session.
        4)  All of these time values are GMT time values.
        5)  The disconnect time value will be zero if the sesson has never been
            disconnected.}
      CurrentTime := FileTime2DateTime(Info.CurrentTime);
      LastInputTime := FileTime2DateTime(Info.LastInputTime);

      // Disconnected session = idle since DisconnectTime
      if YearOf(LastInputTime) = 1601 then
        LastInputTime := FileTime2DateTime(Info.DisconnectTime);

      IdleTime := LastInputTime - CurrentTime;
      Days := Trunc(IdleTime);
      Hours := HourOf(IdleTime);
      Minutes := MinuteOf(IdleTime);
      if Days > 0 then
        sIdleTime := Format('%dd %d:%1.2d', [Days, Hours, Minutes])
      else
      if Hours > 0 then
        sIdleTime := Format('%d:%1.2d', [Hours, Minutes])
      else
      if Minutes > 0 then
        sIdleTime := IntToStr(Minutes)
      else
        sIdleTime := '-';
    end;
  except
    Result := False;
  end;
end;

{$ENDIF JWA_INTERFACESECTION}

{$IFNDEF JWA_OMIT_SECTIONS}
end.
{$ENDIF JWA_OMIT_SECTIONS}
