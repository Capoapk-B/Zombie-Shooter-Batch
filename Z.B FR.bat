@echo off
chcp 65001 > nul
setlocal EnableDelayedExpansion
title ZOMBIE SHOOTER BATCH

for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"

<nul set /p "=%ESC%[?25l"

set posh=20
set posl=10
set pv=100
set pv_max=100
set score=0
set munitions=5
set max_ennemis=25
set tours=0
set deplacement_count=0
set kills=0
set nb_ennemis=0
set nb_obstacles=0
set zone=1
set biome=1

set "BLACK=[30m"
set "RED=[31m"
set "GREEN=[32m"
set "YELLOW=[33m"
set "BLUE=[34m"
set "MAGENTA=[35m"
set "CYAN=[36m"
set "WHITE=[37m"
set "RESET=[0m"

set "BG_BLACK=[40m"
set "BG_RED=[41m"
set "BG_GREEN=[42m"
set "BG_YELLOW=[43m"
set "BG_BLUE=[44m"
set "BG_MAGENTA=[45m"
set "BG_CYAN=[46m"
set "BG_WHITE=[47m"
set "GREEN=%ESC%[32m"
set "YELLOW=%ESC%[33m"
set "BLUE=%ESC%[34m"
set "MAGENTA=%ESC%[35m"
set "CYAN=%ESC%[36m"
set "RED=%ESC%[31m"
set "RESET=%ESC%[0m"

set argent=0
set inv_fruit=0
set inv_viande=0
set inv_eau=0

set prix_fruit=5
set prix_viande=10
set prix_eau=4
set prix_munitions=10
set lot_munitions=3
set prix_soin=12
set soin_achat=3

set max_items=8
set delai_item=12
set nb_items=0
set tour_item=0
for /L %%n in (1,1,%max_items%) do set it%%n_actif=0

set "ic1=🍎"
set "ic2=🍌"
set "ic3=🍇"
set "ic4=🍖"
set "ic5=💧"

set nb_biomes=6
set "bg1=42"
set "dc1=🌳"
set "bl1=93"
set "nm1=Foret"
set "bg2=43"
set "dc2=🌵"
set "bl2=31"
set "nm2=Desert"
set "bg3=47"
set "dc3=🌲"
set "bl3=31"
set "nm3=Neige"
set "bg4=46"
set "dc4=🍄"
set "bl4=31"
set "nm4=Marais"
set "bg5=41"
set "dc5=🌋"
set "bl5=93"
set "nm5=Volcan"
set "bg6=100"
set "dc6=🗻"
set "bl6=93"
set "nm6=Montagne"

echo set shell = CreateObject("WScript.Shell") > "%temp%\press_f11.vbs"
echo shell.SendKeys "{F11}" >> "%temp%\press_f11.vbs"

start /b "" cscript //nologo "%temp%\press_f11.vbs"

timeout /t 1 /nobreak >nul
del "%temp%\press_f11.vbs"
set portee=10
set vitesse=40
call :anim
echo   Par CAPOAPK
echo   Copyright 2026 © "ZOMBIE SHOOTER BATCH"
echo   Tous droits reserves et toute reproduction est strictement interdite.
timeout /t 2 /nobreak >nul

set arme=1
set "nom_melee=couteau"
set "ic_melee=🔪"
set gain_melee=5

set GRID_LEFT=15
set KB_LINES=8

set "PAD="
for /L %%p in (0,1,%GRID_LEFT%) do set "PAD=!PAD! "

call :remplir_carte

cls

goto boucle_jeu

:boucle_jeu
call :dessiner_ecran

choice /C 123456789Q0 /N >nul
set "choix=%errorlevel%"

set old_posh=%posh%
set old_posl=%posl%
set moved=0

if %choix%==1 ( set "dh=0" & set "dl=-1" & goto action_tir_direct )
if %choix%==2 ( set /a posh+=1 & set moved=1 )
if %choix%==3 ( set "dh=1" & set "dl=0" & goto action_tir_direct )
if %choix%==4 ( set /a posl-=1 & set moved=1 )
if %choix%==5 ( set "msgg=" & goto boutique )
if %choix%==6 ( set /a posl+=1 & set moved=1 )
if %choix%==7 ( set "dh=-1" & set "dl=0" & goto action_tir_direct )
if %choix%==8 ( set /a posh-=1 & set moved=1 )
if %choix%==9 ( set "dh=0" & set "dl=1" & goto action_tir_direct )
if %choix%==10 ( goto game_over )
if %choix%==11 ( goto changer_arme )

set sortie=0
if %posh% lss 1 ( set "posh=20" & set "sortie=1" )
if %posh% gtr 20 ( set "posh=1" & set "sortie=1" )
if %posl% lss 1 ( set "posl=20" & set "sortie=1" )
if %posl% gtr 20 ( set "posl=1" & set "sortie=1" )
if %sortie%==1 goto changer_zone

for /L %%i in (1,1,%nb_obstacles%) do (
    if %posh%==!obs%%i_h! if %posl%==!obs%%i_l! (
        set posh=%old_posh%
        set posl=%old_posl%
        set moved=0
    )
)

if %moved%==1 set /a deplacement_count+=1

if %deplacement_count% geq 5 (
    set deplacement_count=0
    call :zombie_bruit
)

:verif_ramassage
for /L %%n in (1,1,%max_items%) do (
    if !it%%n_actif!==1 if !it%%n_h!==%posh% if !it%%n_l!==%posl% (
        set it%%n_actif=0
        set /a nb_items-=1
        if !it%%n_type! leq 3 (
            set /a inv_fruit+=1
            set msgg=Vous ramassez un fruit. Fruits : !inv_fruit!
        )
        if !it%%n_type!==4 (
            set /a inv_viande+=1
            set msgg= Vous ramassez de la viande. Viande : !inv_viande!
        )
        if !it%%n_type!==5 (
            set /a inv_eau+=1
            set msgg= Vous ramassez une bouteille d'eau. Eau : !inv_eau!
        )
    )
)

if %r_actif%==1 if %r_h%==%posh% if %r_l%==%posl% call :ramasser_caisse
goto tour_ennemis

:changer_zone
set /a zone+=1
call :nouvelle_carte
call :dessiner_ecran
set msgg=Vous entrez dans une nouvelle zone : %nom_biome% - zone %zone%
goto boucle_jeu

:changer_arme
if %arme%==1 (
    set arme=2
    set "msgg=Arme equipee : %nom_melee% - portee 1, sans munition"
) else (
    set arme=1
    set "msgg=Arme equipee : pistolet"
)
goto boucle_jeu

:boutique
<nul set /p "=%ESC%[H"
cls
echo.    !CYAN!Zone!RESET! %zone% %nom_biome%  📊 !CYAN!Score!RESET! %score%  🔫 %munitions%  🧟 %nb_ennemis%  💲 %argent%  🍎 %inv_fruit%  🍖 %inv_viande%  💧 %inv_eau%%ESC%[K
echo     ❤️ !pv! │!barreVie!│ 
echo.    📑 %msgg%%ESC%[K

echo.
echo   !YELLOW!Vendre!RESET!                              !YELLOW!Acheter!RESET!
echo   [!GREEN!1!RESET!] Un fruit      +%prix_fruit% $%ESC%[K              [!GREEN!6!RESET!] %lot_munitions% munitions     -%prix_munitions% $%ESC%[K
echo   [!GREEN!2!RESET!] Une viande    +%prix_viande% $%ESC%[K             [!GREEN!7!RESET!] Se soigner +%soin_achat% PV    -%prix_soin% $%ESC%[K
echo   [!GREEN!3!RESET!] Une eau       +%prix_eau% $%ESC%[K              
echo   [!GREEN!4!RESET!] Tout vendre%ESC%[K                                
echo.
echo   [!GREEN!5!RESET!] Retour a la carte
choice /C 1234567 /N
if %errorlevel%==7 goto acheter_soin
if %errorlevel%==6 goto acheter_munitions
if %errorlevel%==5 goto boucle_jeu
if %errorlevel%==4 goto vendre_tout
if %errorlevel%==3 goto vendre_eau
if %errorlevel%==2 goto vendre_viande
if %errorlevel%==1 goto vendre_fruit

:vendre_fruit
if %inv_fruit% leq 0 (
    set "msgg=%ESC%[91mVous n'avez aucun fruit a vendre.%ESC%[0m"
    goto boutique
)
set /a inv_fruit-=1
set /a argent+=prix_fruit
set "msgg=%ESC%[92mFruit vendu : +%prix_fruit% $%ESC%[0m"
goto boutique

:vendre_viande
if %inv_viande% leq 0 (
    set "msgg=%ESC%[91mVous n'avez pas de viande a vendre.%ESC%[0m"
    goto boutique
)
set /a inv_viande-=1
set /a argent+=prix_viande
set "msgg=%ESC%[92mViande vendue : +%prix_viande% $%ESC%[0m"
goto boutique

:vendre_eau
if %inv_eau% leq 0 (
    set "msgg=%ESC%[91mVous n'avez pas d'eau a vendre.%ESC%[0m"
    goto boutique
)
set /a inv_eau-=1
set /a argent+=prix_eau
set "msgg=%ESC%[92mEau vendue : +%prix_eau% $%ESC%[0m"
goto boutique

:vendre_tout
set /a total=inv_fruit*prix_fruit+inv_viande*prix_viande+inv_eau*prix_eau
if %total% leq 0 (
    set "msgg=%ESC%[91mVotre sac est vide.%ESC%[0m"
    goto boutique
)
set /a argent+=total
set inv_fruit=0
set inv_viande=0
set inv_eau=0
set "msgg=%ESC%[92mTout vendu : +%total% $%ESC%[0m"
goto boutique

:acheter_munitions
if %argent% lss %prix_munitions% (
    set "msgg=%ESC%[91mPas assez d'argent.%ESC%[0m"
    goto boutique
)
set /a argent-=prix_munitions
set /a munitions+=lot_munitions
set "msgg=%ESC%[92m+%lot_munitions% munitions achetees.%ESC%[0m"
goto boutique

:acheter_soin
if %pv% geq %pv_max% (
    set "msgg=%ESC%[93mVos PV sont deja au maximum.%ESC%[0m"
    goto boutique
)
if %argent% lss %prix_soin% (
    set "msgg=%ESC%[91mPas assez d'argent.%ESC%[0m"
    goto boutique
)
set /a argent-=prix_soin
set /a pv_avant=pv
set /a pv+=soin_achat
if %pv% gtr %pv_max% set pv=%pv_max%
set /a gagne=pv-pv_avant
set "msgg=Vous vous soignez : +%gagne% PV pour %prix_soin%"
goto boutique

:action_tir_direct
if %arme%==2 goto action_melee
if %munitions% leq 0 goto action_melee

set /a munitions-=1

set th=%posh%
set tl=%posl%
set dist=0
set "sym=%ESC%[%sol%;%bul%m• %ESC%[0m"

:boucle_balle
set /a "th+=dh, tl+=dl, dist+=1"

if %dist% gtr %portee% goto tir_portee
if %th% lss 1 goto tir_rate
if %th% gtr 20 goto tir_rate
if %tl% lss 1 goto tir_rate
if %tl% gtr 20 goto tir_rate

set hit_obs=0
for /L %%o in (1,1,%nb_obstacles%) do (
    if !obs%%o_h!==%th% if !obs%%o_l!==%tl% set hit_obs=1
)
if !hit_obs!==1 goto tir_arbre

set hit_zom=0
for /L %%i in (1,1,%max_ennemis%) do (
    if !e%%i_actif!==1 if !e%%i_h!==%th% if !e%%i_l!==%tl% (
        set zid=%%i
        set hit_zom=1
    )
)
if !hit_zom!==1 goto tir_touche

call :poser
call :attente
goto boucle_balle

:tir_touche
set e%zid%_actif=0
set /a nb_ennemis-=1
set /a kills+=1
set /a gain=5+dist
set /a score+=gain
set "sym=%ESC%[%sol%m💥%ESC%[0m"
call :poser
set msgg= En plein dans le mille ^^! Zombie abattu - distance %dist% - +%gain% 
    powershell -c "[console]::beep(150, 200)"
goto tour_ennemis

:tir_arbre
set msgg= Pof ^^! La balle se plante dans le decor.
    powershell -c "[console]::beep(150, 200)"
goto tour_ennemis

:tir_portee
set msgg= Trop loin ^^! La balle retombe sans toucher personne
    powershell -c "[console]::beep(150, 200)"
goto tour_ennemis

:tir_rate
set msgg=  Tir rate... La balle se perd au loin.
    powershell -c "[console]::beep(150, 200)"
goto tour_ennemis

:action_melee
set "pre="
if %arme%==1 set "pre=Plus de munitions - "

set /a "th=posh+dh, tl=posl+dl"

if %th% lss 1 goto melee_bord
if %th% gtr 20 goto melee_bord
if %tl% lss 1 goto melee_bord
if %tl% gtr 20 goto melee_bord

set hit_obs=0
for /L %%o in (1,1,%nb_obstacles%) do (
    if !obs%%o_h!==%th% if !obs%%o_l!==%tl% set hit_obs=1
)
if !hit_obs!==1 goto melee_decor

set hit_zom=0
for /L %%i in (1,1,%max_ennemis%) do (
    if !e%%i_actif!==1 if !e%%i_h!==%th% if !e%%i_l!==%tl% (
        set zid=%%i
        set hit_zom=1
    )
)
if !hit_zom!==1 goto melee_touche
goto melee_vide

:melee_touche
set e%zid%_actif=0
set /a nb_ennemis-=1
set /a kills+=1
set /a score+=gain_melee
set "sym=%ESC%[%sol%m💥%ESC%[0m"
call :poser
set msgg=%pre%Zombie abattu d'un coup de %nom_melee% - +%gain_melee%
    powershell -c "[console]::beep(150, 200)"
goto tour_ennemis

:melee_vide
set "sym=%ESC%[%sol%m💨%ESC%[0m"
call :poser
set msgg=%pre%Coup de %nom_melee% dans le vide
    powershell -c "[console]::beep(400, 60)"
goto tour_ennemis

:melee_decor
set msgg=%pre%Le coup de %nom_melee% heurte le decor
    powershell -c "[console]::beep(400, 60)"
goto tour_ennemis

:melee_bord
set msgg=%pre%Coup de %nom_melee% dans le vide - bord de la carte
    powershell -c "[console]::beep(400, 60)"
goto tour_ennemis

:tour_ennemis
set /a tours+=1

set /a tour_item+=1
if %tour_item% lss %delai_item% goto fin_spawn_item
set tour_item=0
if %nb_items% lss %max_items% call :spawn_item
:fin_spawn_item

if %tours% geq 2 (
    set /a tours=0
    for /L %%i in (1,1,%max_ennemis%) do (
        if !e%%i_actif!==1 (
            set /a eh=!e%%i_h!
            set /a el=!e%%i_l!

            if !eh! lss %posh% set /a eh+=1
            if !eh! gtr %posh% set /a eh-=1
            if !el! lss %posl% set /a el+=1
            if !el! gtr %posl% set /a el-=1

            set z_hit=0
            for /L %%o in (1,1,%nb_obstacles%) do (
                if !eh!==!obs%%o_h! if !el!==!obs%%o_l! set z_hit=1
            )
            
            if !z_hit!==0 (
                for /L %%j in (1,1,%max_ennemis%) do (
                    if "!e%%j_actif!"=="1" if %%j neq %%i (
                        if !eh!==!e%%j_h! if !el!==!e%%j_l! set z_hit=1
                    )
                )
                if "!r_actif!"=="1" if !eh!==!r_h! if !el!==!r_l! set z_hit=1
            )

            if !z_hit!==0 (
                set e%%i_h=!eh!
                set e%%i_l=!el!
            )
        )
    )
)

for /L %%i in (1,1,%max_ennemis%) do (
    if !e%%i_actif!==1 (
        if !e%%i_h!==%posh% if !e%%i_l!==%posl% (
            set /a pv-=1
            set msgg= ARGH ^^! Un zombie vous a mordu ^^! -1 PV
        )
    )
)

if %pv% leq 0 goto game_over
goto boucle_jeu

:dessiner_ecran

set "barreVie="
for /L %%A in (10,10,100) do (
    if %%A LEQ !pv! (
        set "barreVie=!barreVie!!RED!█!RESET!"
    ) else (
        set "barreVie=!barreVie!░"
    )
)

set "ic_arme=🔫"
set "nom_arme=pistolet"
if %arme%==2 set "ic_arme=%ic_melee%" & set "nom_arme=%nom_melee%"

for /L %%o in (1,1,%nb_obstacles%) do set "cell_!obs%%o_h!_!obs%%o_l!=%decor%"
for /L %%f in (1,1,%max_items%) do (
    if !it%%f_actif!==1 for %%t in (!it%%f_type!) do set "cell_!it%%f_h!_!it%%f_l!=!ic%%t!"
)
set "cell_%posh%_%posl%=🤵"
if %r_actif%==1 set "cell_%r_h%_%r_l%=📦"
for /L %%k in (1,1,%max_ennemis%) do (
    if !e%%k_actif!==1 set "cell_!e%%k_h!_!e%%k_l!=🧟"
)

for /L %%i in (1,1,20) do (
    set "line="
    for /L %%j in (1,1,20) do (
        if defined cell_%%i_%%j (
            set "line=!line!!cell_%%i_%%j!"
            set "cell_%%i_%%j="
        ) else (
            set "line=!line!  "
        )
    )
    set "row%%i=!line!"
)

<nul set /p "=%ESC%[?2026h%ESC%[H%ESC%[2J"
cls
echo.    !CYAN!Zone!RESET! %zone% %nom_biome%  📊 !CYAN!Score!RESET! %score%  🔫 %munitions%  🧟 %nb_ennemis%  💲 %argent%  🍎 %inv_fruit%  🍖 %inv_viande%  💧 %inv_eau%%ESC%[K
echo     ❤️ !pv! │!barreVie!│   
echo.    📑 %msgg%%ESC%[K
for /L %%i in (1,1,20) do echo.%PAD%%ESC%[%sol%m!row%%i!%ESC%[0m%ESC%[K

echo                         --------------------------%ESC%[K
echo                      ---------  !GREEN!5!RESET!  ----  !GREEN!0!RESET!  ---------%ESC%[K
echo                    ------  !CYAN!8!RESET!  ---------------  !RED!7!RESET!  -----%ESC%[K
echo                  --------- ⬆ ----------------- ⬆ ---------%ESC%[K
echo                ----  !CYAN!4!RESET!  ← 🤵 ➜  !CYAN!6!RESET!  ----  !RED!1!RESET!  ← !ic_arme! ➜  !RED!9!RESET!  -----%ESC%[K
echo                  --------- ⬇ ----------------- ⬇ ---------%ESC%[K
echo                    ------  !CYAN!2!RESET!  ---------------  !RED!3!RESET!  ------%ESC%[K
echo                          -----               -----            

<nul set /p "=%ESC%[?2026l"
exit /b

:poser

set /a bl_up=KB_LINES+21-th
set /a bl_col=GRID_LEFT+2*tl
<nul set /p "x=%ESC%[!bl_up!A%ESC%[!bl_col!G!sym!%ESC%[!bl_up!B%ESC%[1G"
exit /b

:attente
ping -n 1 -w %vitesse% 192.0.2.1 >nul
exit /b


:nouvelle_carte
:tirage_biome
set /a nb_tmp=!random! %% nb_biomes + 1
if %nb_tmp%==%biome% goto tirage_biome
set biome=%nb_tmp%

:remplir_carte
set "sol=!bg%biome%!"
set "decor=!dc%biome%!"
set "bul=!bl%biome%!"
set "nom_biome=!nm%biome%!"

for /L %%i in (1,1,20) do (
    set obs%%i_h=0
    set obs%%i_l=0
)
set /a nb_obstacles=8 + !random! %% 13
for /L %%i in (1,1,%nb_obstacles%) do (
    call :place_libre
    set obs%%i_h=!pl_h!
    set obs%%i_l=!pl_l!
)

set nb_items=0
for /L %%n in (1,1,%max_items%) do set it%%n_actif=0
set /a nb_depart=3 + !random! %% 4
for /L %%n in (1,1,%nb_depart%) do call :spawn_item

for /L %%i in (1,1,%max_ennemis%) do set e%%i_actif=0
set nb_ennemis=0
set /a nb_depart=2 + zone / 2 + !random! %% 3
if %nb_depart% gtr 12 set nb_depart=12
for /L %%i in (1,1,%nb_depart%) do call :spawn_zombie

call :place_libre
set /a r_h=pl_h
set /a r_l=pl_l
set r_actif=1
exit /b

:place_libre
set /a pl_h=!random! %% 20 + 1
set /a pl_l=!random! %% 20 + 1
set pl_ok=1

for /L %%o in (1,1,%nb_obstacles%) do (
    if !obs%%o_h!==!pl_h! if !obs%%o_l!==!pl_l! set pl_ok=0
)
if !pl_h!==!posh! if !pl_l!==!posl! set pl_ok=0

if "!r_actif!"=="1" if !pl_h!==!r_h! if !pl_l!==!r_l! set pl_ok=0

for /L %%n in (1,1,%max_items%) do (
    if "!it%%n_actif!"=="1" if !it%%n_h!==!pl_h! if !it%%n_l!==!pl_l! set pl_ok=0
)

for /L %%i in (1,1,%max_ennemis%) do (
    if "!e%%i_actif!"=="1" if !e%%i_h!==!pl_h! if !e%%i_l!==!pl_l! set pl_ok=0
)

if !pl_ok!==0 goto place_libre
exit /b

:place_loin
call :place_libre
set /a zd1=pl_h-posh
set /a zd2=pl_l-posl
if !zd1! lss 0 set /a zd1=-zd1
if !zd2! lss 0 set /a zd2=-zd2
if !zd1! lss 5 if !zd2! lss 5 goto place_loin
exit /b

:spawn_item
set iid=0
for /L %%q in (1,1,%max_items%) do (
    if !iid!==0 if !it%%q_actif!==0 set iid=%%q
)
if %iid%==0 exit /b
call :place_libre
set /a it%iid%_h=pl_h
set /a it%iid%_l=pl_l
set /a it%iid%_type=!random! %% 5 + 1
set it%iid%_actif=1
set /a nb_items+=1
exit /b

:spawn_zombie
set slot_z=0
for /L %%q in (1,1,%max_ennemis%) do (
    if !slot_z!==0 if !e%%q_actif!==0 set slot_z=%%q
)
if %slot_z%==0 exit /b
call :place_loin
set /a e%slot_z%_h=pl_h
set /a e%slot_z%_l=pl_l
set e%slot_z%_actif=1
set /a nb_ennemis+=1
exit /b

:zombie_bruit
set nb_avant=%nb_ennemis%
call :spawn_zombie
if %nb_ennemis% gtr %nb_avant% (
    set msgg=Le bruit de vos pas attire un zombie 
)
exit /b

:ramasser_caisse
set /a score+=10
set /a munitions+=3
set msgg= Ravitaillement trouve 
set nb_avant=%nb_ennemis%
call :spawn_zombie
if %nb_ennemis% gtr %nb_avant% (
    set msgg= Un zombie rodait pres de la caisse 
)
call :place_libre
set /a r_h=pl_h
set /a r_l=pl_l
exit /b

:anim
echo.
echo.
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET!  
echo                  !BG_WHITE!@@@@@@@@@@@@@@@@@@@!RESET!  
echo                !BG_WHITE!@@@@@@@@@@@@@@@@@@@@@@@!RESET! 
echo               !BG_WHITE!@@@@@@@@@@@@@@@@@@@@@@@@@!RESET! 
echo               !BG_WHITE!@@@@@@@@@@@@@@@@@@@@@@@@@!RESET! 
echo               !BG_WHITE!@@@@@@!RESET!     !BG_WHITE!@@@!RESET!     !BG_WHITE!@@@@@@!RESET! 
echo               !BG_WHITE!@@@@!RESET!        !BG_WHITE!@!RESET!        !BG_WHITE!@@@@!RESET! 
echo               !BG_WHITE!@@@!RESET!         !BG_WHITE!@!RESET!         !BG_WHITE!@@@!RESET!              
echo               !BG_WHITE!@@@!RESET!        !BG_WHITE!@@@!RESET!        !BG_WHITE!@@@!RESET!
echo                !BG_WHITE!@@@@@!RESET!  !BG_WHITE!@@@!RESET!   !BG_WHITE!@@@!RESET!  !BG_WHITE!@@@@@!RESET! 
echo                  !BG_WHITE!@@@@@@@!RESET!     !BG_WHITE!@@@@@@@!RESET! 
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET! 
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET!
echo                     !BG_WHITE!@!RESET!!RED!│││││││││││!RESET!!BG_WHITE!@!RESET!
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET! 
timeout /t 1 /nobreak >nul
cls
echo.
echo.
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET!  
echo                  !BG_WHITE!@@@@@@@@@@@@@@@@@@@!RESET!  
echo                !BG_WHITE!@@@@@@@@@@@@@@@@@@@@@@@!RESET! 
echo               !BG_WHITE!@@@@@@@@@@@@@@@@@@@@@@@@@!RESET! 
echo               !BG_WHITE!@@@@@@@@@@@@@@@@@@@@@@@@@!RESET! 
echo               !BG_WHITE!@@@@@@!RESET!     !BG_WHITE!@@@!RESET!     !BG_WHITE!@@@@@@!RESET! 
echo               !BG_WHITE!@@@@!RESET!        !BG_WHITE!@!RESET!        !BG_WHITE!@@@@!RESET! 
echo               !BG_WHITE!@@@!RESET!         !BG_WHITE!@!RESET!         !BG_WHITE!@@@!RESET! 
echo               !BG_WHITE!@@@!RESET!        !BG_WHITE!@@@!RESET!        !BG_WHITE!@@@!RESET!
echo                !BG_WHITE!@@@@@!RESET!  !BG_WHITE!@@@!RESET!   !BG_WHITE!@@@!RESET!  !BG_WHITE!@@@@@!RESET! 
echo                  !BG_WHITE!@@@@@@@!RESET!     !BG_WHITE!@@@@@@@!RESET! 
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET! 
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET! 
echo                     !BG_WHITE!@!RESET!!RED!││││││ ││││!RESET!!BG_WHITE!@!RESET!
echo.                    !BG_WHITE!@!RESET!           !BG_WHITE!@!RESET!
echo                     !BG_WHITE!@!RESET!!RED!│││ │││││││!RESET!!BG_WHITE!@!RESET!
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET!
timeout /t 1 /nobreak >nul
cls
echo.
echo.
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET!  
echo                  !BG_WHITE!@@@@@@@@@@@@@@@@@@@!RESET!  
echo                !BG_WHITE!@@@@@@@@@@@@@@@@@@@@@@@!RESET! 
echo               !BG_WHITE!@@@@@@@@@@@@@@@@@@@@@@@@@!RESET! 
echo               !BG_WHITE!@@@@@@@@@@@@@@@@@@@@@@@@@!RESET! 
echo               !BG_WHITE!@@@@@@!RESET!     !BG_WHITE!@@@!RESET!     !BG_WHITE!@@@@@@!RESET! 
echo               !BG_WHITE!@@@@!RESET!        !BG_WHITE!@!RESET!        !BG_WHITE!@@@@!RESET! 
echo               !BG_WHITE!@@@!RESET!         !BG_WHITE!@!RESET!         !BG_WHITE!@@@!RESET! 
echo               !BG_WHITE!@@@!RESET!        !BG_WHITE!@@@!RESET!        !BG_WHITE!@@@!RESET!
echo                !BG_WHITE!@@@@@!RESET!  !BG_WHITE!@@@!RESET!   !BG_WHITE!@@@!RESET!  !BG_WHITE!@@@@@!RESET! 
echo                  !BG_WHITE!@@@@@@@!RESET!     !BG_WHITE!@@@@@@@!RESET! 
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET! 
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET! 
echo                     !BG_WHITE!@!RESET!!RED!││││││ ││││!RESET!!BG_WHITE!@!RESET!
echo.                    !BG_WHITE!@!RESET!           !BG_WHITE!@!RESET!
echo.                    !BG_WHITE!@!RESET!           !BG_WHITE!@!RESET!
echo                     !BG_WHITE!@!RESET!!RED!│││ │││││││!RESET!!BG_WHITE!@!RESET!
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET!
timeout /t 1 /nobreak >nul
cls
echo.
echo.
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET!  
echo                  !BG_WHITE!@@@@@@@@@@@@@@@@@@@!RESET!  
echo                !BG_WHITE!@@@@@@@@@@@@@@@@@@@@@@@!RESET! 
echo               !BG_WHITE!@@@@@@@@@@@@@@@@@@@@@@@@@!RESET! 
echo               !BG_WHITE!@@@@@@@@@@@@@@@@@@@@@@@@@!RESET! 
echo               !BG_WHITE!@@@@@@!RESET!     !BG_WHITE!@@@!RESET!     !BG_WHITE!@@@@@@!RESET! 
echo               !BG_WHITE!@@@@!RESET!        !BG_WHITE!@!RESET!        !BG_WHITE!@@@@!RESET! 
echo               !BG_WHITE!@@@!RESET!         !BG_WHITE!@!RESET!         !BG_WHITE!@@@!RESET! 
echo               !BG_WHITE!@@@!RESET!        !BG_WHITE!@@@!RESET!        !BG_WHITE!@@@!RESET!
echo                !BG_WHITE!@@@@@!RESET!  !BG_WHITE!@@@!RESET!   !BG_WHITE!@@@!RESET!  !BG_WHITE!@@@@@!RESET! 
echo                  !BG_WHITE!@@@@@@@!RESET!     !BG_WHITE!@@@@@@@!RESET! 
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET! 
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET! 
echo                     !BG_WHITE!@!RESET!!RED!││││││ ││││!RESET!!BG_WHITE!@!RESET!
echo.                    !BG_WHITE!@!RESET!           !BG_WHITE!@!RESET!
echo.                    !BG_WHITE!@!RESET!           !BG_WHITE!@!RESET!
echo.                    !BG_WHITE!@!RESET!           !BG_WHITE!@!RESET!
echo                     !BG_WHITE!@!RESET!!RED!│││ │││││││!RESET!!BG_WHITE!@!RESET!
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET!
echo.
echo.
timeout /t 1 /nobreak >nul
cls

echo. !RESET!
echo.
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET!  
echo                  !BG_WHITE!@@@@@@@@@@@@@@@@@@@!RESET!  
echo                !BG_WHITE!@@@@@@@@@@@@@@@@@@@@@@@!RESET! 
echo               !BG_WHITE!@@@@@@@@@@@@@@@@@@@@@@@@@!RESET! 
echo               !BG_WHITE!@@@@@@@@@@@@@@@@@@@@@@@@@!RESET! 
echo               !BG_WHITE!@@@@@@!RESET!     !BG_WHITE!@@@!RESET!     !BG_WHITE!@@@@@@!RESET! 
echo               !BG_WHITE!@@@@!RESET!        !BG_WHITE!@!RESET!        !BG_WHITE!@@@@!RESET! 
echo               !BG_WHITE!@@@!RESET!         !BG_WHITE!@!RESET!         !BG_WHITE!@@@!RESET! 
echo               !BG_WHITE!@@@!RESET!        !BG_WHITE!@@@!RESET!        !BG_WHITE!@@@!RESET!
echo                !BG_WHITE!@@@@@!RESET!  !BG_WHITE!@@@!RESET!   !BG_WHITE!@@@!RESET!  !BG_WHITE!@@@@@!RESET! 
echo                  !BG_WHITE!@@@@@@@!RESET!     !BG_WHITE!@@@@@@@!RESET! 
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET! 
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET! 
echo                     !BG_WHITE!@!RESET!!RED!│││││││││││!RESET!!BG_WHITE!@!RESET!
echo                     !BG_WHITE!@@@@@@@@@@@@@!RESET!
echo.
echo.
exit /b


:game_over
cls
<nul set /p "=%ESC%[?25h"
call :anim
echo   Score final : %score%
echo   Zombies abattus : %kills%
echo   Zombies survivants : %nb_ennemis%
echo   Zone atteinte : %zone%
echo   Argent restant : %argent% $
echo.
goto fin

:fin
<nul set /p "=%ESC%[?25h"
echo.
pause
endlocal
exit /b