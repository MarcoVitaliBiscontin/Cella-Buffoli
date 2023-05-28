MODULE MainModule           !IRB1200_1
    
    !Definizione targhet workobject
    PERS tooldata tPinza1:=[TRUE,[[0,131.5,119.5],[0.707107,-0.707107,0,0]],[1,[1,0,0],[1,0,0,0],1,0,0]];
    PERS wobjdata Workobject_2:=[FALSE,TRUE,"",[[-631.818,445.037,623.744],[0.308398,-0.636169,-0.636535,-0.308225]],[[0,0,0],[1,0,0,0]]];
    PERS wobjdata Workobject_CNC:=[FALSE,TRUE,"",[[-578.208,-379.632,-390.8],[0.130525,-0.991445,-0.000283969,0.000034679]],[[0,0,0],[1,0,0,0]]];
    CONST robtarget pPrelievo:=[[631.818008834,-445.03693584,623.744032081],[0.667909755,0.231769089,0.668046323,0.232150294],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST jointtarget JointTarget_1:=[[0,0,0,0,30,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget pSopraPrelievo:=[[415.760780129,-445.160676309,623.745186118],[0.667909783,0.23176905,0.668046305,0.232150305],[-1,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget pJPosizioneIntermedia:=[[415.495083256,18.774190557,640.454135542],[0.499853695,0.173377377,0.801583244,0.27847957],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget pAppDeposito:=[[578.179010088,432.165286731,-194.741041306],[0.00361548,0.002684145,0.793344344,0.6087565],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget pDeposito:=[[578.208404223,379.632100945,-390.799627139],[0.003615655,0.002684074,0.793344301,0.608756555],[0,-1,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    CONST num TempoLavoroTransfer:=5;              !TEmpo di lavorazione del singolo pezzo nel transfer

    
    PROC main()
        pHome;                                  !Spostamento posizione home
        
        Set doCreaPezzo;                        !Creazione pezzo
        
        Reset doApriPinzaCNC;                   !Reset di tutti gli ingressi
        Reset doApriPinza;
        Reset doAttacca;
        Reset doChiudiPinza;
        Reset doChiudiPinzaCNC;
        Reset doCreaPezzo;
        Reset doRitiraPezzo;
        
        FOR i FROM 0 TO 11 DO                   !Carica 12 pezzi nel transfer all'inizio
            PrelievoPezzo;                      !Prelevva il pezzo
            DepositoPezzo;                      !Deposita il pezzo
            WaitTime TempoLavoroTransfer;
            
            Set doNAscondiPezzoCarico;          !Grafica nascondi pezzo caricato
            Reset doNAscondiPezzoCarico;        !Reset grafica nascondi pezzo caricato
        ENDFOR
        
        Set doRitiraPezzo;                     !Imposta ritira pezzo IRB1200_2
        WaitTime 1;
        
        WHILE TRUE DO                           !Carico Transfer
            Reset doRitiraPezzo;
            
            PrelievoPezzo;                      !Preleva il pezzo
            WaitDI diPezzoRitirato,1;           !Attende trasfer libero
            
            DepositoPezzo;                      !Deposita il pezzo
            Set doRitiraPezzo;
            WaitTime 1;
            Reset doRitiraPezzo;                !Reset deposita il pezzo
        ENDWHILE
 
    ENDPROC
    PROC DepositoPezzo()                        !Procedura deposito pezzo nel transfer
        
        Set doApriPinzaCNC;                     !Apre la pinza della Transfer 
        
        !Movimento nella CNC 
        MoveJ pJPosizioneIntermedia,vmax,z100,tPinza1\WObj:=wobj0;
        MoveJ pAppDeposito,vmax,z100,tPinza1\WObj:=wobj0;
        MoveL pDeposito,v150,fine,tPinza1\WObj:=wobj0;
        
        Reset doChiudiPinza;                    !Reset segnale
        Set doChiudiPinzaCNC;                   !Chiusura pinza Transfer
        WaitTime 1.1;                           !Attesa Pinca Transfer Chiusa
        Reset doChiudiPinzaCNC;                 !Reset segnale
        Set doApriPinza;                        !Apertura pinza robot
        Reset doAttacca;                        !Simulazione stacca il pezzo
        
        !Movimento fuori Transfer
        MoveL pAppDeposito,vmax,z100,tPinza1\WObj:=wobj0;   
        
        !Creazione pezzo nastro ingresso
        Set doCreaPezzo;
        WaitTime 0.1;
        Reset doCreaPezzo;
        
        !Movimento posizione di prelievo pezzo in ingresso
        MoveJ pJPosizioneIntermedia,vmax,z100,tPinza1\WObj:=wobj0;      !Posizione intermedia per evitare collisioni
        MoveJ pSopraPrelievo,vmax,z100,tPinza1\WObj:=wobj0;
        
        !Reset di tutti i segnali
        Reset doApriPinzaCNC;
        Reset doApriPinza;
        Reset doAttacca;
        Reset doChiudiPinza;
        Reset doChiudiPinzaCNC;
        Reset doCreaPezzo;
        Reset doRitiraPezzo;
    ENDPROC
    PROC PrelievoPezzo()                        !Procedura prelievo pezzo da nastro ingresso
        
        !Movimento posizione sopra prelievo
        MoveJ pSopraPrelievo,vmax,z100,tPinza1\WObj:=wobj0;
        
        !Apertura pinza
        Set doApriPinza;
        WaitTime 1.1;
        
        !Movimento posizione Prelievo
        MoveL pPrelievo,v150,fine,tPinza1\WObj:=wobj0;
        
        Reset doApriPinza;                      !Reset segnale
        Set doChiudiPinza;                      !Chiusura pinza
        Set doAttacca;                          !Simulazione attacca pezzo
        WaitTime 1.1;
        
        !Movimento sopra prelievo
        MoveL pSopraPrelievo,vmax,z100,tPinza1\WObj:=wobj0;
        
        !Reset di tutti i segnali
        Reset doApriPinzaCNC;
        Reset doApriPinza;
        Reset doChiudiPinza;
        Reset doChiudiPinzaCNC;
        Reset doCreaPezzo;
    ENDPROC
    
    PROC pHome()                                !Procedura posizione di Home
        MoveAbsJ JointTarget_1,vmax,z100,tPinza1\WObj:=wobj0;
    ENDPROC
ENDMODULE