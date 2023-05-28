MODULE MainModule               !IRB4600
    
    !Definizione targhet workobject
    PERS tooldata tPinza3:=[TRUE,[[0,0,194.6],[1,0,0,0]],[1,[1,0,0],[1,0,0,0],1,0,0]];
    CONST robtarget pCassetta1Pallet1:=[[141.407996912,194.723321321,126.001044016],[-0.000000026,-0.000000066,1,0.000000027],[-1,0,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget pHomePosition:=[[569.72978229,-1293.811182203,1005.950669794],[-0.000000027,0.258818691,0.965925921,0.000000043],[-1,-1,-1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS jointtarget jHome:=[[0,0,0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget pDepTavRotante:=[[-1382.187591192,302.577824965,320.185930628],[-0.000000109,-0.002072459,0.999997852,0.000000028],[1,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST wobjdata wobjPallet1_Prel:=[FALSE,TRUE,"",[[-1233.762500075,-977.129306018,-172],[0.866995013,0,0,-0.498316814]],[[0,0,0],[1,0,0,0]]];
    CONST wobjdata wobjPallet2_Prel:=[FALSE,TRUE,"",[[171.157379299,-915.586638568,-172],[0.866995013,0,0,-0.498316814]],[[0,0,0],[1,0,0,0]]];
    CONST wobjdata wobjPallet1_Dep:=[FALSE,TRUE,"",[[909.350663715,203.770884853,-172],[0.965710913,0,0,0.259619784]],[[0,0,0],[1,0,0,0]]];
    CONST wobjdata wobjPallet2_Dep:=[FALSE,TRUE,"",[[-693.27384335,711.861953568,-172],[0.965710913,0,0,0.259619784]],[[0,0,0],[1,0,0,0]]];
    PERS wobjdata wobjTavRot:=[FALSE,TRUE,"",[[0,0,40],[1,0,0,0]],[[0,0,0],[1,0,0,0]]];
    
    !Definizione variabili workobject e costanti
    CONST num AltezzaPallet:=1;
    CONST num Profondit‡Pallet:=2;
    CONST num LunghezzaPallet:=4;
    PERS num NumScatole:=8;
    PERS num NumScatole_livello:=8;
    PERS num xScatola:=0;
    PERS num yScatola:=1;
    PERS num zScatola:=0;
    PERS num xScatola_dep:=0;
    PERS num yScatola_dep:=0;
    PERS num zScatola_dep:=0;
    PERS num nscatola:=0;
    PERS wobjdata wobjPrel:=[FALSE,TRUE,"",[[-1233.76,-977.129,-172],[0.866995,0,0,-0.498317]],[[0,0,0],[1,0,0,0]]];
    PERS wobjdata wobjDep:=[FALSE,TRUE,"",[[909.351,203.771,-172],[0.965711,0,0,0.25962]],[[0,0,0],[1,0,0,0]]];
    
    
    PROC main()

        HomePosition;                                                   !Home Position
        
        WaitDI diStart,1;                                               !Attende Pressione Tasto Start
        
        !Calcolo variabili
        NumScatole:=AltezzaPallet*Profondit‡Pallet*LunghezzaPallet;
        NumScatole_livello:= Profondit‡Pallet*LunghezzaPallet;
        xScatola:=0;
        yScatola:=0;
        zScatola:=0;
        xScatola_dep:=0;
        yScatola_dep:=0;
        zScatola_dep:=0;
        nScatola:=0;
        
        AperturaPinza;                                                  !Apertura Pinza
        WaitTime 2;
        
        label2:
        
        !Imposta i workobject
        wobjPrel:=[FALSE,TRUE,"",[[-1233.762500075,-977.129306018,-172],[0.866995013,0,0,-0.498316814]],[[0,0,0],[1,0,0,0]]];
        wobjDep:=[FALSE,TRUE,"",[[909.350663715,203.770884853,-172],[0.965710913,0,0,0.259619784]],[[0,0,0],[1,0,0,0]]];
        
        label1:
        RotazioneTavolaB;                                               !Ruota Tavola B
        
        !Ciclo prelievo e deposito scatole
        FOR nScatola FROM 0 TO NumScatole DO
            
            IF nscatola<>Numscatole THEN                                !Se la scatola non Ë l'ultima
                
                Prelievo_scatole(nScatola);                             !Preleva la scatola
                DepositoSuTavRotante;                                   !Deposita sulla tavola rotante
                IF nScatola<>0 THEN                                     !Se la scatola non Ë la prima
                    WaitDI diPezzoSuNastro,1;                           !Attendi segnale scatola piena
                    WaitTime 5;
                ENDIF   
            ENDIF
            
            IF (nScatola MOD 2)=0 THEN                                  !Fai ruotare una volta in A una volta in B la tavola rotante
                RotazioneTavolaA;
            ELSE
                RotazioneTavolaB;
            ENDIF
            
            IF nScatola<>0 THEN                                         !Se la scatola non Ë la prima 
                
                PrelievoDaTavRotante;                                   !Preleva dalla tavola rotante
                
                Deposito_scatole(nScatola);                             !Deposita sul pallet di deposito
            ENDIF
        ENDFOR
        
        nScatola:=0;
        
        
        IF wobjPrel<>wobjPallet2_Prel THEN                              !Cambio workobject
        
            wobjPrel:=[FALSE,TRUE,"",[[171.157379299,-915.586638568,-172],[0.866995013,0,0,-0.498316814]],[[0,0,0],[1,0,0,0]]];
            wobjDep:=[FALSE,TRUE,"",[[-693.27384335,711.861953568,-172],[0.965710913,0,0,0.259619784]],[[0,0,0],[1,0,0,0]]];
            
            WaitTime 5;
            Set doPallet3_Pieno;                                        !Ritira pallet_dep_1 UniBOT 2000
            WaitTime 3;
            Reset doPallet3_Pieno;
                
            GOTO label1;                                                !Ricomoncio il ciclo con pallet cambiato
            
        ELSE
            WaitTime 5;
            Set doPallet4_Pieno;                                        !Ritira pallet_dep_2 UniBOT 2000
            WaitTime 3;
            Reset doPallet4_Pieno;
            
            GOTO label2;                                                !Ricomoncio il ciclo con pallet cambiato
            
        ENDIF
        
        HomePosition;

    ENDPROC

    
    PROC Prelievo_scatole(num nScatola)                                 !Procedura prelievo scatole, Ingresso: numero scatola
        
        !Calcolo posizione scatola dato il numero della scatola
        zScatola:=AltezzaPallet-1-(nScatola DIV NumScatole_livello);
        xScatola:=(nScatola-(nScatola DIV NumScatole_livello)*NumScatole_livello) DIV Profondit‡Pallet;
        yScatola:=((nScatola-(nScatola DIV NumScatole_livello)*NumScatole_livello)-xScatola*Profondit‡Pallet);
        
        !Muoviti sulla scatola
        MoveJ Offs(pCassetta1Pallet1,302*xScatola,yScatola*407,750),vmax,z10,tPinza3\WObj:=wobjPrel;
        SingArea\Wrist;
        ConfL\Off;
        MoveL Offs(pCassetta1Pallet1,302*xScatola,yScatola*407,(zScatola*105)),v150,fine,tPinza3\WObj:=wobjPrel;

        ChiusuraPinza;                                                  !Chiudi Pinza
        
        !Alzati sopra la scatola 
        MoveL Offs(pCassetta1Pallet1,302*xScatola,yScatola*407,(zScatola*105)+100),v200,z10,tPinza3\WObj:=wobjPrel;
        MoveL Offs(pCassetta1Pallet1,302*xScatola,yScatola*407,750),vmax,z10,tPinza3\WObj:=wobjPrel;
        
        
        
    ENDPROC
    
    PROC Deposito_scatole(num nScatola)                                 !Procedura deposito scatole, Ingresso: numero scatola
        
        !Calcolo posizione scatola dato il numero della scatola
        nScatola:=NumScatole-nScatola;
        zScatola_dep:=AltezzaPallet-1-(nScatola DIV NumScatole_livello);
        xScatola_dep:=((nScatola-(nScatola DIV NumScatole_livello)*NumScatole_livello) DIV Profondit‡Pallet);
        yScatola_dep:=((nScatola-(nScatola DIV NumScatole_livello)*NumScatole_livello)-xScatola_dep*Profondit‡Pallet);
        
        !Muoviti sulla scatola
        MoveJ Offs(pCassetta1Pallet1,302*xScatola_dep,yScatola_dep*407,750),vmax,z10,tPinza3\WObj:=wobjDep;
        MoveL Offs(pCassetta1Pallet1,302*xScatola_dep,yScatola_dep*407,zScatola_dep*105),v150,fine,tPinza3\WObj:=wobjDep;
        
        AperturaPinza;                                                  !Apri pinza
        
        !Alzati sopra la scatola 
        MoveL Offs(pCassetta1Pallet1,302*xScatola_dep,yScatola_dep*407,zScatola_dep*105+100),v200,z10,tPinza3\WObj:=wobjDep;
        MoveL Offs(pCassetta1Pallet1,302*xScatola_dep,yScatola_dep*407,750),vmax,z10,tPinza3\WObj:=wobjDep;

    ENDPROC

    PROC RotazioneTavolaA()                                             !Procedura rotazione tavola in posizione A
        Reset doStazioneB;
        WaitTime 0.1;
        Set doStazioneA;
        WaitTime 2;
        !
    ENDPROC

    PROC RotazioneTavolaB()                                             !Procedura rotazione tavola in posizione B
        Reset doStazioneA;
        WaitTime 0.1;
        Set doStazioneB;
        WaitTime 2;
        !
    ENDPROC

    PROC AperturaPinza()                                                 !Procedura Apertura pinza
        Reset doChiusuraPinza;
        WaitTime 0.1;
        Set doAperturaPinza;
        WaitTime 0.5;
        Reset doAttacca;
        !
    ENDPROC

    PROC ChiusuraPinza()                                                 !Procedura Chiusra pinza
        Reset doAperturaPinza;
        WaitTime 0.1;
        Set doChiusuraPinza;
        WaitTime 0.5;
        Set doAttacca;
        !
    ENDPROC


    PROC HomePosition()                                                 !Procedura posizione Home
        MoveJ pHomePosition,v500,fine,tPinza3\WObj:=wobj0;
    ENDPROC

    PROC DepositoSuTavRotante()                                          !Procedura Deposito su tavola rotante
        
        !Muoviti sopra la tavola rotante
        MoveJ Offs(pDepTavRotante,0,0,300),vmax,z10,tPinza3\WObj:=wobjTavRot;
        MoveL pDepTavRotante,v150,fine,tPinza3\WObj:=wobjTavRot;
        
        AperturaPinza;                                                  !Apri la pinza
        
        !Muoviti sopra deposito tavola rotante
        MoveL Offs(pDepTavRotante,0,0,300),vmax,z10,tPinza3\WObj:=wobjTavRot;
    ENDPROC

    PROC PrelievoDaTavRotante()                                         !Procedura Prelievo da tavola rotante
        
        !Muoviti sopra la tavola rotante
        MoveJ Offs(pDepTavRotante,0,0,300),vmax,z10,tPinza3\WObj:=wobjTavRot;
        MoveL pDepTavRotante,v150,fine,tPinza3\WObj:=wobjTavRot;
        
        ChiusuraPinza;                                                  !Chiudi pinza
        
        !Muoviti sopra deposito tavola rotante
        MoveL Offs(pDepTavRotante,0,0,300),vmax,z10,tPinza3\WObj:=wobjTavRot;
    ENDPROC

ENDMODULE