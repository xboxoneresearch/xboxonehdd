
                            [ Englishize Cmd v1.7a ]

             http://wandersick.blogspot.com | wandersick@gmail.com

     [ What? ]

  .  Toggles between English and non-English for most Windows commands.

  .  For English system admins who manages Windows PCs of other languages.
  
  .  No need to log off; settings are appled immediately.
  
  .  Comes with a restorer too. Apply or restore is as simple as a click.
  
  .  Better character compatibility than changing DOS codepage.
  
  .  Most languages and executables are supported. Customizable.
  
  .  Administrator rights are required. It asks for rights to elevates itself.
     Does not elevate over network mapped drives however.
  
  .  Windows Vista or above only (Windows Vista/7/8/8.1, Server 2008/2012[R2])

     [ Instructions ]
  
  1. "Englishize.bat" for changing command line tools from non-English to
      English.
      
  2. "Restore.bat" to restore everything back to original language.
      
  3. "_lang_codes.txt" is a modifiable list containing all non-English language
      codes. It includes most languages but in case your language is not there,
      add it and "Englishize Cmd" will support it.
      
  4. "_files_to_process.txt" is a modifiable list of file names of command-line
     executables that will be affected in the change. All commands in Windows
     Vista and 7 should be covered (although it contains much more commands
     than there actually are, it doesn't matter because it has no effect on
     commands that don't exist.)
     
     If you decide some commands are better left localized rather than being
     changed to English, remove them from the list before running "Englishize.
     bat".
     
     Also, although the list covers command-line executables, you can add GUI
     -- Graphical User Interface - programs such as Paint - mspaint.exe and
     lots of others to "_files_to_process.txt". There is a limitation here
     though. Windows comes with both English and non-English .mui files for
     command-line programs only; by default .mui for GUI programs don't exist
     in en-US folder until users install the English MUI through Windows
     Update) or Vistalizator (for non-Ultimate/Enterprise Windows users).
     
     [ Video Demo ]
         
     http://wandersick.blogspot.com/p/change-non-english-command-line.html

     [ Releases ]

       1.7a   A quick fix to patch the recently updated restore.bat which
              launched incorrect batch script during elevation.
       1.7    Fixes non-stop prompting when run as standard user w/o UAC.
              Added a note: it is normal to see 'not enough storage' error     
       1.6a   A quick fix to improve the last version.
       1.6    Fixed bug in some non-English localized versions of Windows
              where 'Administrators' group account is named something else.
              Thanks Markus (echalone).
              Confirmed working in Windows 8.1.
       1.5    Support for mui files under %systemroot%\syswow64.
              Restorer now restores original permissions and ownership
              Confirmed working in Windows 8. Updated with new CLI tools.
       1.4a   Fixed a significant bug of last version. _lang_codes.txt should
              not have any 'en-XX' otherwise even English is disabled.
       1.4    Improved _lang_codes.txt so that all system languages are
              supported. (Please report if your locale is not included)
       1.3    Now elevates automatically. Added check for Windows version.
       1.2    Documentation and coding improvements
       1.1    Added check for admin rights
       1.0    First public release

     [ Suggestions ]

  #  Do you have one? Please drop me a line by email or the web site atop.
  
