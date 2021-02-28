@echo off
@echo ---------------------------------------------------------
@echo Converting non-script text files to data files
@echo ---------------------------------------------------------
@echo.
@copy custom_text.txt custom_text_TMP.txt > NUL
@copy enemynames_short.txt enemynames_short_TMP.txt > NUL
@copy castroll_names.txt castroll_names_TMP.txt > NUL
@copy special_itemdescriptions.txt special_itemdescriptions_TMP.txt > NUL
@python prepare_special_text.py custom_text_TMP.txt custom_text.txt
@python prepare_special_text.py enemynames_short_TMP.txt enemynames_short.txt
@python prepare_special_text.py castroll_names_TMP.txt castroll_names.txt
@python prepare_special_text.py custom_text_TMP.txt special_itemdescriptions.txt
@textconv
@fix_custom_text text_custom_text.bin
@copy custom_text_TMP.txt custom_text.txt > NUL
@copy enemynames_short_TMP.txt enemynames_short.txt > NUL
@copy castroll_names_TMP.txt castroll_names.txt > NUL
@copy special_itemdescriptions_TMP.txt special_itemdescriptions.txt > NUL
@del custom_text_TMP.txt > NUL
@del enemynames_short_TMP.txt > NUL
@del castroll_names_TMP.txt > NUL
@del special_itemdescriptions_TMP.txt > NUL
@echo.
@echo.
@echo ---------------------------------------------------------
@echo Copying base ROM (mother3.gba) to new test ROM (test.gba)
@echo ---------------------------------------------------------
@echo.
@copy mother3j.gba test.gba
@FreeSpace
@echo.
@echo.
@echo ---------------------------------------------------------
@echo Converting audio .snd files to data files
@echo ---------------------------------------------------------
@echo.
@soundconv readysetgo.snd lookoverthere_eng.snd
@echo.
@echo.
@echo ---------------------------------------------------------
@echo Creating pre-welded cast of characters & sleep mode text
@echo ---------------------------------------------------------
@echo.
@m3preweld
@echo.
@echo.
@echo ---------------------------------------------------------
@echo Checking overlap of the files that will be used
@echo ---------------------------------------------------------
@echo.
@python check_overlap.py m3hack.asm
@echo.
@echo.
@echo ---------------------------------------------------------
@echo Compiling .asm files and inserting all new data files
@echo ---------------------------------------------------------
@echo.
@xkas test.gba m3hack.asm
@echo.
@echo.
@FreeSpace
@echo COMPLETE!
@echo.
@PAUSE