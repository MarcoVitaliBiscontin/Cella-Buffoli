MODULE MainModule       !IRB1200_2
    
    !Definizione targhet workobject
    PERS tooldata tPinza2:=[TRUE,[[0,131.5,119.5],[1,0,0,0]],[1,[0,1,0],[1,0,0,0],1,0,0]];
    PERS wobjdata Workobject_CNC:=[FALSE,TRUE,"",[[-575.664,205.684,-383.927],[0.130525,-0.991445,-0.000283969,0.000034679]],[[0,0,0],[1,0,0,0]]];
    CONST jointtarget pHome:=[[0,0,0,0,30,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget pJIntermedia:=[[80.721468154,190.198348213,-654.738997707],[0.707106769,-0.000000001,-0.000000005,0.707106793],[0,-1,1,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget pAvvPrelievo:=[[0.000027166,0.000074695,-111.974905387],[0.707106769,-0.000000001,-0.000000005,0.707106793],[-1,0,0,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget pPrelievo:=[[0,0,0],[0.707106781,0,0,0.707106781],[-1,0,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget pAvvDeposito:=[[62.89492025,300.087992656,-1076.999028959],[0.707106781,0,-0.707106781,0],[0,0,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    CONST robtarget pDeposito:=[[-81.031625591,300.0879997,-1076.999009713],[0.707106781,0,-0.707106781,0],[0,0,-1,1],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    
    
    CONST num nPezziPerScatola:=2;              !Numero di pezzi desiderati per scatola
    CONST num TempoLavoroTransfer:=5;              !TEmpo di lavorazione del singolo pezzo nel transfer
    PERS num Pezzi:=0;



    PROC main()
        Home;                                   !Spostamento in posizione Home
        
        !Reset di tutti gli ingressi
        Reset doApriPinzaCNC;                   
        Reset doApriPinza;
        Reset doAttacca;
        Reset doChiudiPinza;
        Reset doChiudiPinzaCNC;
        Reset doStaccaPEzzoCNC;
        Reset doPezzoSuNastro;
        Pezzi:=0;                               !Imposta variabile pezzi a 0
        
        !Ciclo while Prelievo pezzo lavorato dal transfer e deposito pezzo sul nastro di uscita
        WHILE TRUE DO
            WaitDI diRitiraPezzo,1;             !Attendi comando ritira pezzo
            WaitTime TempoLavoroTransfer;       !Attendi tempo di lavoro transfer
            
            PrelievoPezzo;                      !Preleva il pezzo
            Set doPezzoRitirato;                !Avvisa che il pezzo e stato ritirato 
                                                !per permettere il carico di uno nuovo
                                                
            DepositoPezzo;                      !Deposito pezzo su nastro di uscita
            WaitTime 1;
            
            Set doStaccaPEzzoCNC;               !Grafica 
            Pezzi:=Pezzi+1;                     !Incremento numero pezzo
            
            Reset doStaccaPEzzoCNC;             !Reset grafica
            
            !Raggiunti i pezzi per scatola desiderati ritira da IRB4600
            IF Pezzi=nPezziPerScatola THEN
                Set doPezzoSuNastro;            !Ritira IRB4600
                WaitTime 1;
                Reset doPezzoSuNastro;          !Reset ritira IRB4600
                Pezzi:=0;                       !Azzeramento pezzi per scatola
            ENDIF
            
            Reset doPezzoRitirato;              !Reset pezzo ritirato
            
        ENDWHILE
        
        Home;
        
    ENDPROC
    PROC PrelievoPezzo()                        !Procedura prelievo pezzo da trasnfer
        
        !Movimento nel trasfer
        MoveJ pJIntermedia,vmax,z200,tPinza2\WObj:=Workobject_CNC;
        MoveJ pAvvPrelievo,vmax,z200,tPinza2\WObj:=Workobject_CNC;
        MoveL pPrelievo,v150,fine,tPinza2\WObj:=Workobject_CNC;
        
        Set doChiudiPinza;                      !Chiusura pinza
        WaitTime 1.1;                           !Attesa pinza chiusa
        Set doAttacca;                          !Grafica attacca pezzo
        Set doApriPinzaCNC;                     !Apertura pinza Transfer
        WaitTime 0.5;                           !attesa pinza aperta 
                                                !Tempo minore in quanto basta che la pinza si apra poco
        
        !Allontanamento 
        MoveL pAvvPrelievo,vmax,z200,tPinza2\WObj:=Workobject_CNC;
        MoveJ pJIntermedia,vmax,z200,tPinza2\WObj:=Workobject_CNC;
        
        !Reset segnali
        Reset doApriPinzaCNC;
        Reset doChiudiPinza;
        
        
    ENDPROC
    PROC DepositoPezzo()                        !Procedura deposito pezzo su nastro di uscita
        
        !Movimento su posizione di deposito
        MoveJ pAvvDeposito,vmax,z200,tPinza2\WObj:=Workobject_CNC;
        MoveL pDeposito,vmax,z200,tPinza2\WObj:=Workobject_CNC;
        
        Set doApriPinza;                        !Apertura pinza
        WaitTime 1;                             !Attesa tempo apertura pinza
        Reset doAttacca;                        !Grafica stacca pezzo
        
        Set doStaccaPEzzoCNC;                   !Grafica stacca pezzo e movimento su nastro
        Reset doStaccaPEzzoCNC;                 !Grafica reset segnale
        
        !Movimento attesa seguente prelievo
        MoveL pAvvDeposito,vmax,z200,tPinza2\WObj:=Workobject_CNC;
        MoveJ pJIntermedia,vmax,z200,tPinza2\WObj:=Workobject_CNC;
        
        !Reset segnali
        Reset doApriPinza; 
    ENDPROC
    
    PROC Home()                                 !Procedura posizione Home
        
        MoveAbsJ pHome,vmax,z200,tPinza2\WObj:=Workobject_CNC;
        Set doApriPinza;                        !Apertura pinza
    ENDPROC
ENDMODULE