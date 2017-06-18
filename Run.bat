call C:\MSC.Software\Marc\setup_intel.bat 13 0 2012
call C:\MSC.Software\Marc\2015.0.0\marc2015\tools\run_marc.bat -j C:\Users\gw1012\4thYearProject\matlab\CallusForm5\callusform5_job1.dat -back no -nthread 2  -u C:\Users\gw1012\4thYearProject\matlab\CallusForm5\Modulus.f
call C:\Python27\python.exe C:\Users\gw1012\4thYearProject\matlab\CallusForm5\Back_out_NEW.py
move C:\Users\gw1012\4thYearProject\matlab\CallusForm5\*.t16 C:\Users\gw1012\4thYearProject\matlab\CallusForm5\Results_files\