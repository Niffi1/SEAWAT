C
      SUBROUTINE IMT1SSM4AL(INSSM,IOUT,ISUM,ISUM2,NCOL,NROW,NLAY,NCOMP,
     & LCIRCH,LCRECH,LCCRCH,LCIEVT,LCEVTR,LCCEVT,MXSS,LCSS,IVER,LCSSMC)
C **********************************************************************
C THIS SUBROUTINE ALLOCATES SPACE FOR ARRAYS NEEDED IN THE SINK & SOURCE
C MIXING (SSM) PACKAGE.
C **********************************************************************
C last modified: 05-15-2003
C
      IMPLICIT  NONE
      INTEGER   INSSM,IOUT,ISUM,ISUM2,NCOL,NROW,NLAY,NCOMP,
     &          LCIRCH,LCRECH,LCCRCH,LCIEVT,LCEVTR,LCCEVT,
     &          MXSS,LCSS,ISUMX,ISUMIX,NCR,ISOLD,ISOLD2,IVER,LCSSMC
      CHARACTER LINE*200
      LOGICAL   FWEL,FDRN,FRCH,FEVT,FRIV,FGHB,
     &          FSTR,FRES,FFHB,FIBS,FTLK,FLAK,FMAW,FDRT,FETS,FUSR(3)
C--SEAWAT: CHANGED COMMON NAME FC TO FCMT3D TO AVOID CONFLICT WITH SUBROUTINE
      COMMON /FCMT3D/FWEL,FDRN,FRCH,FEVT,FRIV,FGHB,
     &           FSTR,FRES,FFHB,FIBS,FTLK,FLAK,FMAW,FDRT,FETS,FUSR
C
C--PRINT PACKAGE NAME AND VERSION NUMBER
      WRITE(IOUT,1000) INSSM
 1000 FORMAT(1X,'SSM4 -- SINK & SOURCE MIXING PACKAGE,',
     & ' VERSION 4.5, MAY 2003, INPUT READ FROM UNIT',I3)
C
C--READ AND PRINT FLAGS INDICATING WHICH SINK/SOURCE OPTIONS
C--ARE USED IN FLOW MODEL
      IF(IVER.EQ.1) THEN
        READ(INSSM,'(6L2)') FWEL,FDRN,FRCH,FEVT,FRIV,FGHB
      ELSEIF(IVER.EQ.2) THEN
        READ(INSSM,'(A)') LINE
        WRITE(IOUT,1010) LINE
      ENDIF
      WRITE(IOUT,1020)
      IF(FWEL) WRITE(IOUT,1340)
      IF(FDRN) WRITE(IOUT,1342)
      IF(FRCH) WRITE(IOUT,1344)
      IF(FEVT) WRITE(IOUT,1346)
      IF(FRIV) WRITE(IOUT,1348)
      IF(FGHB) WRITE(IOUT,1350)
      IF(FSTR) WRITE(IOUT,1400)
      IF(FRES) WRITE(IOUT,1402)
      IF(FFHB) WRITE(IOUT,1404)
      IF(FIBS) WRITE(IOUT,1406)
      IF(FTLK) WRITE(IOUT,1408)
      IF(FLAK) WRITE(IOUT,1410)
      IF(FMAW) WRITE(IOUT,1412)
      IF(FDRT) WRITE(IOUT,1414)
      IF(FETS) WRITE(IOUT,1416)
      IF(FUSR(1)) WRITE(IOUT,1418)
      IF(FUSR(2)) WRITE(IOUT,1420)
      IF(FUSR(3)) WRITE(IOUT,1422)
 1010 FORMAT(/1X,'HEADER LINE OF THE SSM PACKAGE INPUT FILE:',/1X,A)
 1020 FORMAT(1X,'MAJOR STRESS COMPONENTS PRESENT IN THE FLOW MODEL:')
 1340 FORMAT(1X,'o WELL')
 1342 FORMAT(1X,'o DRAIN')
 1344 FORMAT(1X,'o RECHARGE')
 1346 FORMAT(1X,'o EVAPOTRANSPIRATION')
 1348 FORMAT(1X,'o RIVER')
 1350 FORMAT(1X,'o GENERAL-HEAD-DEPENDENT BOUNDARY')
 1400 FORMAT(1X,'o STREAM')
 1402 FORMAT(1X,'o RESERVOIR')
 1404 FORMAT(1X,'o SPECIFIED-HEAD-FLOW BOUNDARY')
 1406 FORMAT(1X,'o INTERBED STORAGE')
 1408 FORMAT(1X,'o TRANSIENT LEAKAGE')
 1410 FORMAT(1X,'o LAKE')
 1412 FORMAT(1X,'o MULTI-AQUIFER WELL')
 1414 FORMAT(1X,'o DRAIN WITH RETURN FLOW')
 1416 FORMAT(1X,'o SEGMENTED EVAPOTRANSPIRATION')
 1418 FORMAT(1X,'o USER-DEFINED NO. 1')
 1420 FORMAT(1X,'o USER-DEFINED NO. 2')
 1422 FORMAT(1X,'o USER-DEFINED NO. 3')
C
C--READ AND PRINT MAXIMUM NUMBER OF
C--POINT SINKS/SOURCES PRESENT IN THE FLOW MODEL
      READ(INSSM,'(I10)') MXSS
      WRITE(IOUT,1580) MXSS
 1580 FORMAT(1X,'MAXIMUM NUMBER OF POINT SINKS/SOURCES =',I8)
C
C--ALLOCATE SPACE FOR ARRAYS
      ISOLD=ISUM
      ISOLD2=ISUM2
      NCR=NCOL*NROW
C
C--INTEGER ARRAYS
      LCIRCH=ISUM2
      IF(FRCH) ISUM2=ISUM2+NCR
      LCIEVT=ISUM2
      IF(FEVT) ISUM2=ISUM2+NCR
C
C--REAL ARRAYS
      LCRECH=ISUM
      IF(FRCH) ISUM=ISUM+NCR
      LCCRCH=ISUM
      IF(FRCH) ISUM=ISUM+NCR * NCOMP
      LCEVTR=ISUM
      IF(FEVT) ISUM=ISUM+NCR
      LCCEVT=ISUM
      IF(FEVT) ISUM=ISUM+NCR * NCOMP
      LCSS=ISUM
      ISUM=ISUM+6*MXSS
      LCSSMC=ISUM
      ISUM=ISUM+NCOMP*MXSS
C
C--CHECK HOW MANY ELEMENTS OF ARRAYS X AND IX ARE USED
      ISUMX=ISUM-ISOLD
      ISUMIX=ISUM2-ISOLD2
      WRITE(IOUT,1090) ISUMX,ISUMIX
 1090 FORMAT(1X,I10,' ELEMENTS OF THE  X ARRAY USED BY THE SSM PACKAGE'
     & /1X,I10,' ELEMENTS OF THE IX ARRAY BY THE SSM PACKAGE'/)
C
C--NORMAL RETURN
      RETURN
      END
C
C
      SUBROUTINE IMT1SSM4RP(IN,IOUT,KPER,NCOL,NROW,NLAY,NCOMP,ICBUND,
     & CNEW,CRCH,CEVT,MXSS,NSS,SS,SSMC)
C ********************************************************************
C THIS SUBROUTINE READS CONCENTRATIONS OF SOURCES OR SINKS NEEDED BY
C THE SINK AND SOURCE MIXING (SSM) PACKAGE.
C ********************************************************************
C last modified: 04-15-2003
C
      IMPLICIT  NONE
      INTEGER   IN,IOUT,KPER,NCOL,NROW,NLAY,NCOMP,ICBUND,
     &          MXSS,NSS,JJ,II,KK,NUM,IQ,INCRCH,INCEVT,NTMP,INDEX
      REAL      CRCH,CEVT,SS,SSMC,CSS,CNEW
      LOGICAL   FWEL,FDRN,FRIV,FGHB,FRCH,FEVT,
     &          FSTR,FRES,FFHB,FIBS,FTLK,FLAK,FMAW,FDRT,FETS,FUSR(3)
      CHARACTER ANAME*24,TYPESS(-1:100)*15
      DIMENSION SS(6,MXSS),SSMC(NCOMP,MXSS),CRCH(NCOL,NROW,NCOMP),
     &          CEVT(NCOL,NROW,NCOMP),
     &          ICBUND(NCOL,NROW,NLAY,NCOMP),CNEW(NCOL,NROW,NLAY,NCOMP)
C--SEAWAT: CHANGED COMMON NAME FC TO FCMT3D TO AVOID CONFLICT WITH SUBROUTINE
      COMMON /FCMT3D/FWEL,FDRN,FRCH,FEVT,FRIV,FGHB,
     &           FSTR,FRES,FFHB,FIBS,FTLK,FLAK,FMAW,FDRT,FETS,FUSR
C
C--INITIALIZE.
      TYPESS(-1)='CONSTANT CONC. '
      TYPESS(1) ='CONSTANT HEAD  '
      TYPESS(2) ='WELL           '
      TYPESS(3) ='DRAIN          '
      TYPESS(4) ='RIVER          '
      TYPESS(5) ='HEAD DEP BOUND '
      TYPESS(15)='MASS LOADING   '
      TYPESS(21)='STREAM         '
      TYPESS(22)='RESERVOIR      '
      TYPESS(23)='SP FLW HD BOUND'
      TYPESS(24)='INTERBED STRG  '
      TYPESS(25)='TRANSIENT LEAK '
      TYPESS(26)='LAKE           '
      TYPESS(27)='MULTI-AQ WELL  '
      TYPESS(28)='DRN W RET FLOW '
      TYPESS(29)='SEGMENTED ET   '
      TYPESS(51)='USER-DEFINED #1'
      TYPESS(52)='USER-DEFINED #2'
      TYPESS(53)='USER-DEFINED #3'
C
C--READ CONCENTRATION OF DIFFUSIVE SOURCES/SINKS (RECHARGE/E.T.)
C--FOR CURRENT STRESS PERIOD IF THEY ARE SIMULATED IN FLOW MODEL
      IF(.NOT.FRCH) GOTO 10
C
C--READ FLAG INCRCH INDICATING HOW TO READ RECHARGE CONCENTRATION
      READ(IN,'(I10)') INCRCH
C
C--IF INCRCH < 0, CONCENTRATIN REUSED FROM LAST STRESS PERIOD
      IF(INCRCH.LT.0) THEN
        WRITE(IOUT,1)
        GOTO 10
      ENDIF
    1 FORMAT(/1X,'CONCENTRATION OF RECHARGE FLUXES',
     & ' REUSED FROM LAST STRESS PERIOD')
C
C--IF INCRCH >= 0, READ AN ARRAY
C--CONTAING CONCENTRATION OF RECHARGE FLUX [CRCH]
      WRITE(IOUT,2) KPER
      ANAME='RECH. CONC. COMP. NO.'
      DO INDEX=1,NCOMP
        WRITE(ANAME(19:21),'(I3.2)') INDEX
        CALL RARRAY(CRCH(1,1,INDEX),ANAME,NROW,NCOL,0,IN,IOUT)
      ENDDO
    2 FORMAT(/1X,'CONCENTRATION OF RECHARGE FLUXES',
     & ' WILL BE READ IN STRESS PERIOD',I3)
C
C--READ CONCENTRAION OF EVAPOTRANSPIRATION FLUX
   10 IF(.NOT.FEVT) GOTO 20
C
      IF(KPER.EQ.1) THEN
        DO INDEX=1,NCOMP
          DO II=1,NROW
            DO JJ=1,NCOL
              CEVT(JJ,II,INDEX)=-1.E-30
            ENDDO
          ENDDO
        ENDDO
      ENDIF
      READ(IN,'(I10)') INCEVT
      IF(INCEVT.LT.0) THEN
        WRITE(IOUT,11)
        GOTO 20
      ENDIF
   11 FORMAT(/1X,'CONCENTRATION OF E. T. FLUXES',
     & ' REUSED FROM LAST STRESS PERIOD')
C
      WRITE(IOUT,12) KPER
      ANAME='E. T. CONC. COMP. NO.'
      DO INDEX=1,NCOMP
        WRITE(ANAME(19:21),'(I3.2)') INDEX
        CALL RARRAY(CEVT(1,1,INDEX),ANAME,NROW,NCOL,0,IN,IOUT)
      ENDDO
   12 FORMAT(/1X,'CONCENTRATION OF E. T. FLUXES',
     & ' WILL BE READ IN STRESS PERIOD',I3)
C
   20 CONTINUE
C
C--READ AND ECHO POINT SINKS/SOURCES OF SPECIFIED CONCENTRATIONS
      READ(IN,'(I10)') NTMP
C
C--RESET OLD CONCENTRATIONS IF REUSE OPTION NOT IN EFFECT
      IF(KPER.GT.1.AND.NTMP.GE.0) THEN
        DO NUM=1,NSS
          SS(4,NUM)=0.
          DO INDEX=1,NCOMP
            SSMC(INDEX,NUM)=0.
          ENDDO
        ENDDO
      ENDIF
C
      IF(NTMP.GT.MXSS) THEN
        WRITE(*,30)
        STOP
      ELSEIF(NTMP.LT.0) THEN
        WRITE(IOUT,40)
        RETURN
      ELSEIF(NTMP.EQ.0) THEN
        WRITE(IOUT,50) NTMP,KPER
        NSS=0
        RETURN
      ELSE
        NSS=NTMP
      ENDIF
C
      WRITE(IOUT,60)
      DO NUM=1,NSS
C
        IF(NCOMP.EQ.1) THEN
          READ(IN,'(3I10,F10.0,I10)') KK,II,JJ,CSS,IQ
          SSMC(1,NUM)=CSS
        ELSE
          READ(IN,'(3I10,F10.0,I10)',ADVANCE='NO') KK,II,JJ,CSS,IQ
          READ(IN,*) (SSMC(INDEX,NUM),INDEX=1,NCOMP)
        ENDIF
C
        IF(IQ.EQ.-1) THEN
          DO INDEX=1,NCOMP
            IF(SSMC(INDEX,NUM).GE.0) THEN
              CNEW(JJ,II,KK,INDEX)=SSMC(INDEX,NUM)
              ICBUND(JJ,II,KK,INDEX)=-ABS(ICBUND(JJ,II,KK,INDEX))
            ENDIF
          ENDDO
        ELSEIF(IQ.EQ.15) THEN
          SS(5,NUM)=0.
        ELSEIF(IQ.LT.1.OR.IQ.GT.100) THEN
          WRITE(*,80)
          STOP
        ENDIF
        SS(1,NUM)=KK
        SS(2,NUM)=II
        SS(3,NUM)=JJ
        SS(4,NUM)=CSS
        SS(6,NUM)=IQ
C
        DO INDEX=1,NCOMP
          CSS=SSMC(INDEX,NUM)
          IF(CSS.GT.0 .OR. ICBUND(JJ,II,KK,INDEX).LT.0)
     &     WRITE(IOUT,70) NUM,KK,II,JJ,CSS,TYPESS(IQ),INDEX
        ENDDO
C
      ENDDO
   30 FORMAT(/1X,'ERROR: MAXIMUM NUMBER OF POINT SINKS/SOURCES',
     & ' EXCEEDED'/1X,'INCREASE [MXSS] IN SSM INPUT FILE')
   40 FORMAT(/1X,'POINT SINKS/SOURCES OF SPECIFIED CONCENTRATION',
     & ' REUSED FROM LAST STRESS PERIOD')
   50 FORMAT(/1X,'NO. OF POINT SINKS/SOURCES OF SPECIFIED',
     & ' CONCONCENTRATIONS =',I5,' IN STRESS PERIOD',I3)
   60 FORMAT(/5X,'  NO    LAYER   ROW   COLUMN   CONCENTRATION',
     & '       TYPE            COMPONENT')
   70 FORMAT(3X,4(I5,3X),1X,G15.7,5X,A15,I6)
   80 FORMAT(/1X,'ERROR: INVALID CODE FOR POINT SINK/SOURCE TYPE',
     & /1X,'IN THE SSM INPUT FILE')
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE IMT1SSM4SV(NCOL,NROW,NLAY,NCOMP,ICOMP,ICBUND,PRSITY,
     & DELR,DELC,DH,RETA,IRCH,RECH,CRCH,IEVT,EVTR,CEVT,MXSS,NTSS,
     & NSS,SS,SSMC,QSTO,CNEW,COLD,DTRANS,MIXELM,ISS,RMASIO)
C ******************************************************************
C THIS SUBROUTINE CALCULATES THE CHANGE IN CELL CONCENTRATIONS
C DUE TO FLUID SOURCE AND SINK MIXING.
C ******************************************************************
C last modified: 08-12-2001
C
      IMPLICIT  NONE
      INTEGER   NCOL,NROW,NLAY,NCOMP,ICOMP,ICBUND,IRCH,IEVT,
     &          MXSS,NTSS,NSS,NUM,IQ,K,I,J,MIXELM,ISS
      REAL      PRSITY,RETA,DTRANS,RECH,CRCH,EVTR,CEVT,SS,SSMC,
     &          CNEW,COLD,CTMP,QSS,DCSSM,RMASIO,DELR,DELC,DH,QSTO
      LOGICAL   FWEL,FDRN,FRCH,FEVT,FRIV,FGHB,
     &          FSTR,FRES,FFHB,FIBS,FTLK,FLAK,FMAW,FDRT,FETS,FUSR(3)
      DIMENSION ICBUND(NCOL,NROW,NLAY,NCOMP),SS(6,MXSS),
     &          SSMC(NCOMP,MXSS),RECH(NCOL,NROW),IRCH(NCOL,NROW),
     &          CRCH(NCOL,NROW,NCOMP),EVTR(NCOL,NROW),IEVT(NCOL,NROW),
     &          CEVT(NCOL,NROW,NCOMP),RETA(NCOL,NROW,NLAY,NCOMP),
     &          PRSITY(NCOL,NROW,NLAY),COLD(NCOL,NROW,NLAY,NCOMP),
     &          CNEW(NCOL,NROW,NLAY,NCOMP),DELR(NCOL),DELC(NROW),
     &          DH(NCOL,NROW,NLAY),QSTO(NCOL,NROW,NLAY),
     &          RMASIO(122,2,NCOMP)
C--SEAWAT: CHANGED COMMON NAME FC TO FCMT3D TO AVOID CONFLICT WITH SUBROUTINE
      COMMON /FCMT3D/FWEL,FDRN,FRCH,FEVT,FRIV,FGHB,
     &           FSTR,FRES,FFHB,FIBS,FTLK,FLAK,FMAW,FDRT,FETS,FUSR
C
C--COPY CONCENTRATION OF ICOMP FROM [SSMC] TO [SS]
      IF(NCOMP.GT.1.AND.NSS.GT.0) THEN
        DO NUM=1,NSS
          SS(4,NUM)=SSMC(ICOMP,NUM)
        ENDDO
      ENDIF
C
C--IF A MIXED EULERIAN-LAGRANGIAN SCHEME NOT USED, GO TO
C--FINITE DIFFERENCE ROUTINE [SSSM4F].
      IF(MIXELM.LE.0) GOTO 350
C
C--TRANSIENT GROUNDWATER STORAGE TERM
      IF(ISS.NE.0) GOTO 50
C
C--RECORD MASS STORAGE CHANGES FOR DISSOLVED AND SORBED PHASES
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(ICBUND(J,I,K,ICOMP).LE.0) CYCLE
            CTMP=COLD(J,I,K,ICOMP)
            IF(QSTO(J,I,K).GT.0) THEN
              RMASIO(118,1,ICOMP)=RMASIO(118,1,ICOMP)
     &         +QSTO(J,I,K)*CTMP*DTRANS*DELR(J)*DELC(I)*DH(J,I,K)
            ELSE
              RMASIO(118,2,ICOMP)=RMASIO(118,2,ICOMP)
     &         +QSTO(J,I,K)*CTMP*DTRANS*DELR(J)*DELC(I)*DH(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--DIFFUSIVE SINK/SOURCE TERMS
C--(RECHARGE)
   50 IF(.NOT.FRCH) GOTO 100
C
      DO I=1,NROW
        DO J=1,NCOL
C
          K=IRCH(J,I)
          IF(K.EQ.0 .OR. ICBUND(J,I,K,ICOMP).LE.0) CYCLE
          CTMP=CRCH(J,I,ICOMP)
          IF(RECH(J,I).LT.0.) THEN
            CTMP=CNEW(J,I,K,ICOMP)
          ELSE
            DCSSM=RECH(J,I)*(CTMP-CNEW(J,I,K,ICOMP))/
     &         (RETA(J,I,K,ICOMP)*PRSITY(J,I,K))*DTRANS
            CNEW(J,I,K,ICOMP)=CNEW(J,I,K,ICOMP)+DCSSM
          ENDIF
C
C--ACCUMULATE MASS IN OR OUT THROUGH THE SOURCE OR SINK
          IF(RECH(J,I).GT.0) THEN
            RMASIO(7,1,ICOMP)=RMASIO(7,1,ICOMP)+RECH(J,I)*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ELSE
            RMASIO(7,2,ICOMP)=RMASIO(7,2,ICOMP)+RECH(J,I)*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ENDIF
        ENDDO
      ENDDO
C
C--(EVAPOTRANSPIRATION)
  100 IF(.NOT.FEVT) GOTO 200
C
      DO I=1,NROW
        DO J=1,NCOL
          K=IEVT(J,I)
          IF(K.EQ.0 .OR. ICBUND(J,I,K,ICOMP).LE.0) CYCLE
          CTMP=CEVT(J,I,ICOMP)
          IF(EVTR(J,I).LT.0.AND.CTMP.LT.0) THEN
            CTMP=CNEW(J,I,K,ICOMP)
          ELSEIF(EVTR(J,I).GE.0.AND.CTMP.LT.0) THEN
            CTMP=0.
          ENDIF
          DCSSM=EVTR(J,I)*(CTMP-CNEW(J,I,K,ICOMP))/
     &     (RETA(J,I,K,ICOMP)*PRSITY(J,I,K))*DTRANS
          CNEW(J,I,K,ICOMP)=CNEW(J,I,K,ICOMP)+DCSSM
C
C--ACCUMULATE MASS IN OR OUT THROUGH THE SOURCE OR SINK
          IF(EVTR(J,I).GT.0) THEN
            RMASIO(8,1,ICOMP)=RMASIO(8,1,ICOMP)+EVTR(J,I)*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ELSE
            RMASIO(8,2,ICOMP)=RMASIO(8,2,ICOMP)+EVTR(J,I)*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ENDIF
        ENDDO
      ENDDO
C
C--POINT SINK/SOURCE TERMS
C--[RESET QSS FOR MASS-LOADING SOURCES (IQ=15)]
  200 DO NUM=1,NTSS
        K=SS(1,NUM)
        I=SS(2,NUM)
        J=SS(3,NUM)
        CTMP=SS(4,NUM)
        QSS=SS(5,NUM)
        IQ=SS(6,NUM)
        IF(IQ.EQ.15) QSS=1./(DELR(J)*DELC(I)*DH(J,I,K))
        IF(ICBUND(J,I,K,ICOMP).GT.0.AND.IQ.GT.0) THEN
          IF(QSS.LT.0) THEN
            CTMP=CNEW(J,I,K,ICOMP)
          ELSE
            DCSSM=QSS*(CTMP-CNEW(J,I,K,ICOMP))/
     &       (RETA(J,I,K,ICOMP)*PRSITY(J,I,K))*DTRANS
            CNEW(J,I,K,ICOMP)=CNEW(J,I,K,ICOMP)+DCSSM
          ENDIF
C
C--ACCUMULATE MASS IN OR OUT THROUGH THE SOURCE OR SINK
          IF(QSS.GT.0) THEN
            RMASIO(IQ,1,ICOMP)=RMASIO(IQ,1,ICOMP)+QSS*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ELSE
            RMASIO(IQ,2,ICOMP)=RMASIO(IQ,2,ICOMP)+QSS*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ENDIF
        ENDIF
      ENDDO
C
      GOTO 400
C
  350 CALL SSSM4F(NCOL,NROW,NLAY,ICBUND(1,1,1,ICOMP),PRSITY,
     & DELR,DELC,DH,RETA(1,1,1,ICOMP),DTRANS,IRCH,RECH,CRCH(1,1,ICOMP),
     & IEVT,EVTR,CEVT(1,1,ICOMP),MXSS,NTSS,NSS,SS,
     & CNEW(1,1,1,ICOMP),COLD(1,1,1,ICOMP),QSTO,ISS,RMASIO(1,1,ICOMP))
C
C--RETURN
  400 RETURN
      END
C
C
      SUBROUTINE SSSM4F(NCOL,NROW,NLAY,ICBUND,PRSITY,DELR,DELC,DH,
     & RETA,DTRANS,IRCH,RECH,CRCH,IEVT,EVTR,CEVT,MXSS,NTSS,NSS,SS,
     & CNEW,COLD,QSTO,ISS,RMASIO)
C ******************************************************************
C THIS SUBROUTINE CALCULATES THE CHANGE IN CELL CONCENTRATIONS
C DUE TO FLUID SOURCE/SINK MIXING WITH THE FINITE DIFFERENCE SCHEME.
C ******************************************************************
C last modified: 08-12-2001
C
      IMPLICIT  NONE
      INTEGER   NCOL,NROW,NLAY,ICBUND,IRCH,IEVT,MXSS,NTSS,NSS,
     &          NUM,IQ,K,I,J,ISS
      REAL      PRSITY,RETA,DTRANS,RECH,CRCH,EVTR,CEVT,SS,CNEW,COLD,
     &          CTMP,QSS,DCSSM,RMASIO,DELR,DELC,DH,QSTO,DCSTO
      LOGICAL   FWEL,FDRN,FRCH,FEVT,FRIV,FGHB,
     &          FSTR,FRES,FFHB,FIBS,FTLK,FLAK,FMAW,FDRT,FETS,FUSR(3)
      DIMENSION ICBUND(NCOL,NROW,NLAY),SS(6,MXSS),
     &          RECH(NCOL,NROW),IRCH(NCOL,NROW),CRCH(NCOL,NROW),
     &          EVTR(NCOL,NROW),IEVT(NCOL,NROW),CEVT(NCOL,NROW),
     &          RETA(NCOL,NROW,NLAY),PRSITY(NCOL,NROW,NLAY),
     &          COLD(NCOL,NROW,NLAY),CNEW(NCOL,NROW,NLAY),
     &          DELR(NCOL),DELC(NROW),DH(NCOL,NROW,NLAY),
     &          QSTO(NCOL,NROW,NLAY),RMASIO(122,2)
C--SEAWAT: CHANGED COMMON NAME FC TO FCMT3D TO AVOID CONFLICT WITH SUBROUTINE
      COMMON /FCMT3D/FWEL,FDRN,FRCH,FEVT,FRIV,FGHB,
     &           FSTR,FRES,FFHB,FIBS,FTLK,FLAK,FMAW,FDRT,FETS,FUSR
C
C--TRANSIENT FLUID STORAGE TERM
      IF(ISS.NE.0) GOTO 50
C
C--RECORD MASS STORAGE CHANGES FOR DISSOLVED AND SORBED PHASES
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(ICBUND(J,I,K).LE.0) CYCLE
            CTMP=COLD(J,I,K)
            DCSTO=QSTO(J,I,K)/(RETA(J,I,K)*PRSITY(J,I,K))*CTMP*DTRANS
            CNEW(J,I,K)=CNEW(J,I,K)+DCSTO
            IF(QSTO(J,I,K).GT.0) THEN
              RMASIO(118,1)=RMASIO(118,1)+QSTO(J,I,K)*CTMP*DTRANS*
     &         DELR(J)*DELC(I)*DH(J,I,K)
            ELSE
              RMASIO(118,2)=RMASIO(118,2)+QSTO(J,I,K)*CTMP*DTRANS*
     &         DELR(J)*DELC(I)*DH(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--DIFFUSIVE SINK/SOURCE TERMS (RECHARGE & E. T.)
   50 IF(.NOT.FRCH) GOTO 100
C
      DO I=1,NROW
        DO J=1,NCOL
          K=IRCH(J,I)
          IF(K.EQ.0 .OR. ICBUND(J,I,K).LE.0) CYCLE
          CTMP=CRCH(J,I)
          IF(RECH(J,I).LT.0) CTMP=COLD(J,I,K)
          DCSSM=RECH(J,I)/(RETA(J,I,K)*PRSITY(J,I,K))*CTMP*DTRANS
          CNEW(J,I,K)=CNEW(J,I,K)+DCSSM
          IF(RECH(J,I).GT.0) THEN
            RMASIO(7,1)=RMASIO(7,1)+RECH(J,I)*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ELSE
            RMASIO(7,2)=RMASIO(7,2)+RECH(J,I)*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ENDIF
   10   ENDDO
      ENDDO
C
  100 IF(.NOT.FEVT) GOTO 200
      DO I=1,NROW
        DO J=1,NCOL
          K=IEVT(J,I)
          IF(K.EQ.0 .OR. ICBUND(J,I,K).LE.0) CYCLE
          CTMP=CEVT(J,I)
          IF(EVTR(J,I).LT.0.AND.CTMP.LT.0) THEN
            CTMP=COLD(J,I,K)
          ELSEIF(EVTR(J,I).GE.0.AND.CTMP.LT.0) THEN
            CTMP=0.
          ENDIF
          DCSSM=EVTR(J,I)/(RETA(J,I,K)*PRSITY(J,I,K))*CTMP*DTRANS
          CNEW(J,I,K)=CNEW(J,I,K)+DCSSM
          IF(EVTR(J,I).GT.0) THEN
            RMASIO(8,1)=RMASIO(8,1)+EVTR(J,I)*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ELSE
            RMASIO(8,2)=RMASIO(8,2)+EVTR(J,I)*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ENDIF
        ENDDO
      ENDDO
C
C--POINT SINK/SOURCE TERMS
C--[RESET QSS FOR MASS-LOADING SOURCES (IQ=15)]
  200 DO NUM=1,NTSS
        K=SS(1,NUM)
        I=SS(2,NUM)
        J=SS(3,NUM)
        CTMP=SS(4,NUM)
        QSS=SS(5,NUM)
        IQ=SS(6,NUM)
        IF(IQ.EQ.15) QSS=1./(DELR(J)*DELC(I)*DH(J,I,K))
        IF(ICBUND(J,I,K).GT.0.AND.IQ.GT.0) THEN
          IF(QSS.LT.0) CTMP=COLD(J,I,K)
          DCSSM=QSS/(RETA(J,I,K)*PRSITY(J,I,K))*CTMP*DTRANS
          CNEW(J,I,K)=CNEW(J,I,K)+DCSSM
          IF(QSS.GT.0) THEN
            RMASIO(IQ,1)=RMASIO(IQ,1)+QSS*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ELSE
            RMASIO(IQ,2)=RMASIO(IQ,2)+QSS*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ENDIF
        ENDIF
      ENDDO
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE IMT1SSM4FM(NCOL,NROW,NLAY,NCOMP,ICOMP,ICBUND,DELR,DELC,
     & DH,IRCH,RECH,CRCH,IEVT,EVTR,CEVT,MXSS,NTSS,SS,SSMC,
     & QSTO,CNEW,ISS,A,RHS,NODES,UPDLHS,MIXELM)
C ******************************************************************
C THIS SUBROUTINE FORMULATES MATRIX COEFFICIENTS FOR THE SINK/
C SOURCE TERMS IF THE IMPLICIT SCHEME IS USED.
C ******************************************************************
C last modified: 08-12-2001
C
      IMPLICIT  NONE
      INTEGER   NCOL,NROW,NLAY,NCOMP,ICOMP,ICBUND,IRCH,IEVT,MXSS,
     &          NTSS,NUM,IQ,K,I,J,ISS,N,NODES,MIXELM
      REAL      CNEW,RECH,CRCH,EVTR,CEVT,SS,SSMC,
     &          CTMP,QSS,DELR,DELC,DH,QSTO,A,RHS
      LOGICAL   UPDLHS,FWEL,FDRN,FRCH,FEVT,FRIV,FGHB,
     &          FSTR,FRES,FFHB,FIBS,FTLK,FLAK,FMAW,FDRT,FETS,FUSR(3)
      DIMENSION ICBUND(NCOL,NROW,NLAY,NCOMP),SS(6,MXSS),
     &          SSMC(NCOMP,MXSS),RECH(NCOL,NROW),IRCH(NCOL,NROW),
     &          CRCH(NCOL,NROW,NCOMP),EVTR(NCOL,NROW),
     &          IEVT(NCOL,NROW),CEVT(NCOL,NROW,NCOMP),
     &          DELR(NCOL),DELC(NROW),CNEW(NCOL,NROW,NLAY,NCOMP),
     &          DH(NCOL,NROW,NLAY),QSTO(NCOL,NROW,NLAY),
     &          A(NODES),RHS(NODES)
C--SEAWAT: CHANGED COMMON NAME FC TO FCMT3D TO AVOID CONFLICT WITH SUBROUTINE
      COMMON /FCMT3D/FWEL,FDRN,FRCH,FEVT,FRIV,FGHB,
     &           FSTR,FRES,FFHB,FIBS,FTLK,FLAK,FMAW,FDRT,FETS,FUSR
C
C--FORMULATE [A] AND [RHS] MATRICES FOR EULERIAN SCHEMES
      IF(MIXELM.GT.0) GOTO 1000
C
C--TRANSIENT FLUID STORAGE TERM
      IF(ISS.EQ.0 .AND. UPDLHS) THEN
        DO K=1,NLAY
          DO I=1,NROW
            DO J=1,NCOL
              IF(ICBUND(J,I,K,ICOMP).GT.0) THEN
                N=(K-1)*NCOL*NROW+(I-1)*NCOL+J
                A(N)=A(N)+QSTO(J,I,K)*DELR(J)*DELC(I)*DH(J,I,K)
              ENDIF
            ENDDO
          ENDDO
        ENDDO
      ENDIF
C
C--AREAL SINK/SOURCE TERMS (RECHARGE & E. T.)
      IF(.NOT.FRCH) GOTO 10
      DO I=1,NROW
        DO J=1,NCOL
          K=IRCH(J,I)
          IF(K.GT.0 .AND. ICBUND(J,I,K,ICOMP).GT.0) THEN
            N=(K-1)*NCOL*NROW+(I-1)*NCOL+J
            IF(RECH(J,I).LT.0) THEN
              IF(UPDLHS) A(N)=A(N)+RECH(J,I)*DELR(J)*DELC(I)*DH(J,I,K)
            ELSE
              RHS(N)=RHS(N)
     &         -RECH(J,I)*CRCH(J,I,ICOMP)*DELR(J)*DELC(I)*DH(J,I,K)
            ENDIF
          ENDIF
        ENDDO
      ENDDO
C
   10 IF(.NOT.FEVT) GOTO 20
      DO I=1,NROW
        DO J=1,NCOL
          K=IEVT(J,I)
          IF(K.GT.0 .AND. ICBUND(J,I,K,ICOMP).GT.0) THEN
            N=(K-1)*NCOL*NROW+(I-1)*NCOL+J
            IF(EVTR(J,I).LT.0.AND.CEVT(J,I,ICOMP).LT.0) THEN
              IF(UPDLHS) A(N)=A(N)+EVTR(J,I)*DELR(J)*DELC(I)*DH(J,I,K)
            ELSEIF(CEVT(J,I,ICOMP).GT.0) THEN
              RHS(N)=RHS(N)
     &         -EVTR(J,I)*CEVT(J,I,ICOMP)*DELR(J)*DELC(I)*DH(J,I,K)
            ENDIF
          ENDIF
        ENDDO
      ENDDO
C
C--POINT SINK/SOURCE TERMS
C--[RESET QSS FOR MASS-LOADING SOURCES (IQ=15)]
   20 DO NUM=1,NTSS
        K=SS(1,NUM)
        I=SS(2,NUM)
        J=SS(3,NUM)
        CTMP=SS(4,NUM)
        IF(NCOMP.GT.1) CTMP=SSMC(ICOMP,NUM)
        QSS=SS(5,NUM)
        IQ=SS(6,NUM)
        IF(IQ.EQ.15) QSS=1./(DELR(J)*DELC(I)*DH(J,I,K))
        IF(ICBUND(J,I,K,ICOMP).GT.0.AND.IQ.GT.0) THEN
          N=(K-1)*NCOL*NROW+(I-1)*NCOL+J
          IF(QSS.LT.0) THEN
            IF(UPDLHS) A(N)=A(N)+QSS*DELR(J)*DELC(I)*DH(J,I,K)
          ELSE
            RHS(N)=RHS(N)-QSS*CTMP*DELR(J)*DELC(I)*DH(J,I,K)
          ENDIF
        ENDIF
      ENDDO
C
C--DONE WITH EULERIAN SCHEMES
      GOTO 2000
C
C--FORMULATE [A] AND [RHS] MATRICES FOR EULERIAN-LAGRANGIAN SCHEMES
 1000 CONTINUE
C
C--AREAL SINK/SOURCE TERMS (RECHARGE & E. T.)
      IF(.NOT.FRCH) GOTO 30
      DO I=1,NROW
        DO J=1,NCOL
          K=IRCH(J,I)
          IF(K.GT.0 .AND. ICBUND(J,I,K,ICOMP).GT.0
     &              .AND. RECH(J,I).GT.0) THEN
            N=(K-1)*NCOL*NROW+(I-1)*NCOL+J
            IF(UPDLHS) A(N)=A(N)-RECH(J,I)*DELR(J)*DELC(I)*DH(J,I,K)
            RHS(N)=RHS(N)
     &       -RECH(J,I)*CRCH(J,I,ICOMP)*DELR(J)*DELC(I)*DH(J,I,K)
          ENDIF
        ENDDO
      ENDDO
C
   30 IF(.NOT.FEVT) GOTO 40
      DO I=1,NROW
        DO J=1,NCOL
          K=IEVT(J,I)
          IF(K.GT.0 .AND. ICBUND(J,I,K,ICOMP).GT.0) THEN
            N=(K-1)*NCOL*NROW+(I-1)*NCOL+J
            IF(EVTR(J,I).LT.0.AND.CEVT(J,I,ICOMP).LT.0) CYCLE
            IF(UPDLHS) A(N)=A(N)-EVTR(J,I)*DELR(J)*DELC(I)*DH(J,I,K)
            IF(CEVT(J,I,ICOMP).GT.0) RHS(N)=RHS(N)
     &       -EVTR(J,I)*CEVT(J,I,ICOMP)*DELR(J)*DELC(I)*DH(J,I,K)
          ENDIF
        ENDDO
      ENDDO
C
C--POINT SINK/SOURCE TERMS
C--[RESET QSS FOR MASS-LOADING SOURCES (IQ=15)]
   40 DO NUM=1,NTSS
        K=SS(1,NUM)
        I=SS(2,NUM)
        J=SS(3,NUM)
        CTMP=SS(4,NUM)
        IF(NCOMP.GT.1) CTMP=SSMC(ICOMP,NUM)
        QSS=SS(5,NUM)
        IQ=SS(6,NUM)
        IF(IQ.EQ.15) QSS=1./(DELR(J)*DELC(I)*DH(J,I,K))
        IF(ICBUND(J,I,K,ICOMP).GT.0.AND.IQ.GT.0.AND.QSS.GT.0) THEN
          N=(K-1)*NCOL*NROW+(I-1)*NCOL+J
          IF(UPDLHS) A(N)=A(N)-QSS*DELR(J)*DELC(I)*DH(J,I,K)
          RHS(N)=RHS(N)-QSS*CTMP*DELR(J)*DELC(I)*DH(J,I,K)
        ENDIF
      ENDDO
C
C--DONE WITH EULERIAN-LAGRANGIAN SCHEMES
 2000 CONTINUE
C
C--RETURN
      RETURN
      END
C
C
      SUBROUTINE IMT1SSM4BD(NCOL,NROW,NLAY,NCOMP,ICOMP,ICBUND,DELR,DELC,
     & DH,IRCH,RECH,CRCH,IEVT,EVTR,CEVT,MXSS,NTSS,SS,SSMC,QSTO,CNEW,
     & RETA,DTRANS,ISS,RMASIO)
C ********************************************************************
C THIS SUBROUTINE CALCULATES MASS BUDGETS ASSOCIATED WITH ALL SINK/
C SOURCE TERMS.
C ********************************************************************
C last modified: 08-12-2001
C
      IMPLICIT  NONE
      INTEGER   NCOL,NROW,NLAY,NCOMP,ICOMP,ICBUND,IRCH,IEVT,MXSS,
     &          NTSS,NUM,IQ,K,I,J,ISS
      REAL      DTRANS,RECH,CRCH,EVTR,CEVT,SS,SSMC,CNEW,
     &          CTMP,QSS,RMASIO,DELR,DELC,DH,QSTO,RETA
      LOGICAL   FWEL,FDRN,FRCH,FEVT,FRIV,FGHB,
     &          FSTR,FRES,FFHB,FIBS,FTLK,FLAK,FMAW,FDRT,FETS,FUSR(3)
      DIMENSION ICBUND(NCOL,NROW,NLAY,NCOMP),SS(6,MXSS),
     &          SSMC(NCOMP,MXSS),RECH(NCOL,NROW),IRCH(NCOL,NROW),
     &          CRCH(NCOL,NROW,NCOMP),EVTR(NCOL,NROW),
     &          IEVT(NCOL,NROW),CEVT(NCOL,NROW,NCOMP),
     &          CNEW(NCOL,NROW,NLAY,NCOMP),DELR(NCOL),DELC(NROW),
     &          DH(NCOL,NROW,NLAY),QSTO(NCOL,NROW,NLAY),
     &          RETA(NCOL,NROW,NLAY,NCOMP),RMASIO(122,2,NCOMP)
C--SEAWAT: CHANGED COMMON NAME FC TO FCMT3D TO AVOID CONFLICT WITH SUBROUTINE
      COMMON /FCMT3D/FWEL,FDRN,FRCH,FEVT,FRIV,FGHB,
     &           FSTR,FRES,FFHB,FIBS,FTLK,FLAK,FMAW,FDRT,FETS,FUSR
C
C--TRANSIENT GROUNDWATER STORAGE TERM
      IF(ISS.NE.0) GOTO 50
C
C--RECORD MASS STORAGE CHANGES FOR DISSOLVED AND SORBED PHASES
      DO K=1,NLAY
        DO I=1,NROW
          DO J=1,NCOL
            IF(ICBUND(J,I,K,ICOMP).LE.0) CYCLE
            CTMP=CNEW(J,I,K,ICOMP)
            IF(QSTO(J,I,K).GT.0) THEN
              RMASIO(118,1,ICOMP)=RMASIO(118,1,ICOMP)
     &         +QSTO(J,I,K)*CTMP*DTRANS*DELR(J)*DELC(I)*DH(J,I,K)
            ELSE
              RMASIO(118,2,ICOMP)=RMASIO(118,2,ICOMP)
     &         +QSTO(J,I,K)*CTMP*DTRANS*DELR(J)*DELC(I)*DH(J,I,K)
            ENDIF
          ENDDO
        ENDDO
      ENDDO
C
C--DIFFUSIVE SINK/SOURCE TERMS
C--(RECHARGE)
   50 IF(.NOT.FRCH) GOTO 100
C
      DO I=1,NROW
        DO J=1,NCOL
C
          K=IRCH(J,I)
          IF(K.EQ.0 .OR. ICBUND(J,I,K,ICOMP).LE.0) CYCLE
          CTMP=CRCH(J,I,ICOMP)
          IF(RECH(J,I).LT.0) CTMP=CNEW(J,I,K,ICOMP)
C
          IF(RECH(J,I).GT.0) THEN
            RMASIO(7,1,ICOMP)=RMASIO(7,1,ICOMP)+RECH(J,I)*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ELSE
            RMASIO(7,2,ICOMP)=RMASIO(7,2,ICOMP)+RECH(J,I)*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ENDIF
C
        ENDDO
      ENDDO
C
C--(EVAPOTRANSPIRATION)
  100 IF(.NOT.FEVT) GOTO 200
C
      DO I=1,NROW
        DO J=1,NCOL
          K=IEVT(J,I)
          IF(K.EQ.0 .OR. ICBUND(J,I,K,ICOMP).LE.0) CYCLE
          CTMP=CEVT(J,I,ICOMP)
          IF(EVTR(J,I).LT.0.AND.CTMP.LT.0) THEN
            CTMP=CNEW(J,I,K,ICOMP)
          ELSEIF(EVTR(J,I).GE.0.AND.CTMP.LT.0) THEN
            CTMP=0.
          ENDIF
C
          IF(EVTR(J,I).GT.0) THEN
            RMASIO(8,1,ICOMP)=RMASIO(8,1,ICOMP)+EVTR(J,I)*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ELSE
            RMASIO(8,2,ICOMP)=RMASIO(8,2,ICOMP)+EVTR(J,I)*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ENDIF
C
        ENDDO
      ENDDO
C
C--POINT SINK/SOURCE TERMS
C--[RESET QSS FOR MASS-LOADING SOURCES (IQ=15)]
  200 DO NUM=1,NTSS
C
        K=SS(1,NUM)
        I=SS(2,NUM)
        J=SS(3,NUM)
        QSS=SS(5,NUM)
        IQ=SS(6,NUM)
        IF(IQ.EQ.15) QSS=1./(DELR(J)*DELC(I)*DH(J,I,K))
        CTMP=SS(4,NUM)
        IF(NCOMP.GT.1) CTMP=SSMC(ICOMP,NUM)
        IF(QSS.LT.0) CTMP=CNEW(J,I,K,ICOMP)
C
        IF(ICBUND(J,I,K,ICOMP).GT.0.AND.IQ.GT.0) THEN
          IF(QSS.GT.0) THEN
            RMASIO(IQ,1,ICOMP)=RMASIO(IQ,1,ICOMP)+QSS*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ELSE
            RMASIO(IQ,2,ICOMP)=RMASIO(IQ,2,ICOMP)+QSS*CTMP*DTRANS*
     &       DELR(J)*DELC(I)*DH(J,I,K)
          ENDIF
        ENDIF
C
      ENDDO
C
C--RETURN
  400 RETURN
      END