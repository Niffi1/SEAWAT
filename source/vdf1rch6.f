      SUBROUTINE VDF1RCH6FM(NRCHOP,IRCH,RECH,RHS,IBOUND,NCOL,NROW,
     &                        NLAY,PS,MTDNCONC,CRCH,NCOMP)
C
C-----VERSION 11JAN2000 GWF1RCH6FM
C     ******************************************************************
C     SUBTRACT RECHARGE FROM RHS
C--SEAWAT: REFORMULATED FOR VD FLOW 
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      DIMENSION IRCH(NCOL,NROW),RECH(NCOL,NROW),
     1          RHS(NCOL,NROW,NLAY),IBOUND(NCOL,NROW,NLAY)
C--SEAWAT: DIMENSION ADDITIONAL ARRAYS
      DIMENSION PS(NCOL,NROW,NLAY),CRCH(NCOL,NROW,NCOMP)
	INCLUDE 'vdf.inc'

C     ------------------------------------------------------------------
C
C1------IF NRCHOP IS 1 RECHARGE IS IN TOP LAYER. LAYER INDEX IS 1.
      IF(NRCHOP.NE.1) GO TO 15
C
      DO 10 IR=1,NROW
      DO 10 IC=1,NCOL
C
C1A-----IF CELL IS EXTERNAL THERE IS NO RECHARGE INTO IT.
		IF(IBOUND(IC,IR,1).LE.0)GO TO 10
		DENSE=DENSEREF
		IF(MTDNCONC.GT.0) DENSE=CALCDENS(CRCH(IC,IR,MTDNCONC))
		IF(RECH(IC,IR).LT.0) DENSE=PS(IC,IR,1)
C
C1B-----SUBTRACT RECHARGE RATE FROM RIGHT-HAND-SIDE.
C--SEAWAT: CONSERVE MASS
C		RHS(IC,IR,1)=RHS(IC,IR,1)-RECH(IC,IR)
		RHS(IC,IR,1)=RHS(IC,IR,1)-RECH(IC,IR)*DENSE
   10 CONTINUE
      GO TO 100
C
C2------IF OPTION IS 2 THEN RECHARGE IS INTO LAYER IN INDICATOR ARRAY
   15 IF(NRCHOP.NE.2)GO TO 25
      DO 20 IR=1,NROW
      DO 20 IC=1,NCOL
C
C2A-----LAYER INDEX IS IN INDICATOR ARRAY.
		IL=IRCH(IC,IR)
C
C2B-----IF THE CELL IS EXTERNAL THERE IS NO RECHARGE INTO IT.
		IF(IBOUND(IC,IR,IL).LE.0)GO TO 20
		DENSE=DENSEREF
		IF(MTDNCONC.GT.0) DENSE=CALCDENS(CRCH(IC,IR,MTDNCONC))
		IF(RECH(IC,IR).LT.0) DENSE=PS(IC,IR,IL)
C
C2C-----SUBTRACT RECHARGE FROM RIGHT-HAND-SIDE.
C--SEAWAT:CONSERVE MASS
C		RHS(IC,IR,IL)=RHS(IC,IR,IL)-RECH(IC,IR)
		RHS(IC,IR,IL)=RHS(IC,IR,IL)-RECH(IC,IR)*DENSE

   20 CONTINUE
      GO TO 100
C
C3------IF OPTION IS 3 RECHARGE IS INTO HIGHEST INTERNAL CELL.
   25 IF(NRCHOP.NE.3)GO TO 100
C        CANNOT PASS THROUGH CONSTANT HEAD NODE
      DO 30 IR=1,NROW
      DO 30 IC=1,NCOL
      DO 28 IL=1,NLAY
C
C3A-----IF CELL IS CONSTANT HEAD MOVE ON TO NEXT HORIZONTAL LOCATION.
		IF(IBOUND(IC,IR,IL).LT.0) GO TO 30
C
C3B-----IF CELL IS INACTIVE MOVE DOWN A LAYER.
		IF (IBOUND(IC,IR,IL).EQ.0)GO TO 28
		DENSE=DENSEREF
		IF(MTDNCONC.GT.0) DENSE=CALCDENS(CRCH(IC,IR,MTDNCONC))
		IF(RECH(IC,IR).LT.0) DENSE=PS(IC,IR,IL)
C
C3C-----SUBTRACT RECHARGE FROM RIGHT-HAND-SIDE.
C--SEAWAT:CONSERVE MASS
C		RHS(IC,IR,IL)=RHS(IC,IR,IL)-RECH(IC,IR)
		RHS(IC,IR,IL)=RHS(IC,IR,IL)-RECH(IC,IR)*DENSE
		GO TO 30
   28 CONTINUE
   30 CONTINUE
  100 CONTINUE
C
C4------RETURN
      RETURN
      END


      SUBROUTINE VDF1RCH6BD(NRCHOP,IRCH,RECH,IBOUND,NROW,NCOL,NLAY,
     1    DELT,VBVL,VBNM,MSUM,KSTP,KPER,IRCHCB,ICBCFL,BUFF,IOUT,
     2    PERTIM,TOTIM,PS,MTDNCONC,CRCH,NCOMP)
C-----VERSION 11JAN2000 GWF1RCH6BD
C     ******************************************************************
C     CALCULATE VOLUMETRIC BUDGET FOR RECHARGE
C--SEAWAT: USE VARIABLE-DENSITY EQUATIONS
C     ******************************************************************
C
C        SPECIFICATIONS:
C     ------------------------------------------------------------------
      DOUBLE PRECISION RATIN,RATOUT,QQ
      CHARACTER*16 VBNM(MSUM),TEXT
      DIMENSION IRCH(NCOL,NROW),RECH(NCOL,NROW),
     1          IBOUND(NCOL,NROW,NLAY),BUFF(NCOL,NROW,NLAY),
     2          VBVL(4,MSUM)
      DATA TEXT /'        RECHARGE'/
C--SEAWAT: DIMENSION ADDITIONAL ARRAYS
      DIMENSION PS(NCOL,NROW,NLAY),CRCH(NCOL,NROW,NCOMP)
	INCLUDE 'vdf.inc'
C     ------------------------------------------------------------------
C
C1------CLEAR THE RATE ACCUMULATORS.
      ZERO=0.
      RATIN=ZERO
      RATOUT=ZERO
C
C2------CLEAR THE BUFFER & SET FLAG FOR SAVING CELL-BY-CELL FLOW TERMS.
      DO 2 IL=1,NLAY
      DO 2 IR=1,NROW
      DO 2 IC=1,NCOL
      BUFF(IC,IR,IL)=ZERO
2     CONTINUE
      IBD=0
      IF(IRCHCB.GT.0) IBD=ICBCFL
C
C3------IF NRCHOP=1 RECH GOES INTO LAYER 1. PROCESS EACH HORIZONTAL
C3------CELL LOCATION.
      IF(NRCHOP.NE.1) GO TO 15
      DO 10 IR=1,NROW
      DO 10 IC=1,NCOL
C
C3A-----IF CELL IS EXTERNAL THEN DO NOT DO BUDGET FOR IT.
      IF(IBOUND(IC,IR,1).LE.0)GO TO 10
		DENSE=DENSEREF
		IF(MTDNCONC.GT.0) DENSE=CALCDENS(CRCH(IC,IR,MTDNCONC))
		IF(RECH(IC,IR).LT.0) DENSE=PS(IC,IR,1)

C--SEAWAT:CONSERVE MASS
C		Q=RECH(IC,IR)
		Q=RECH(IC,IR)*DENSE
		QQ=Q
C
C3B-----ADD RECH TO BUFF.
C--SEAWAT:CONVERT TO VOLUMETRIC FLUX FOR OUTPUT
C		BUFF(IC,IR,1)=Q
		BUFF(IC,IR,1)=Q/DENSE
C
C3C-----IF RECH POSITIVE ADD IT TO RATIN ELSE ADD IT TO RATOUT.
		IF(Q) 8,10,7
    7		RATIN=RATIN+QQ
		GO TO 10
    8		RATOUT=RATOUT-QQ
   10 CONTINUE
      GO TO 100
C
C4------IF NRCHOP=2 RECH IS IN LAYER SHOWN IN INDICATOR ARRAY(IRCH).
C4------PROCESS HORIZONTAL CELL LOCATIONS ONE AT A TIME.
   15 IF(NRCHOP.NE.2) GO TO 24
      DO 20 IR=1,NROW
      DO 20 IC=1,NCOL
C
C4A-----GET LAYER INDEX FROM INDICATOR ARRAY(IRCH).
		IL=IRCH(IC,IR)
C
C4B-----IF CELL IS EXTERNAL DO NOT CALCULATE BUDGET FOR IT.
		IF(IBOUND(IC,IR,IL).LE.0)GO TO 20
		DENSE=DENSEREF
		IF(MTDNCONC.GT.0) DENSE=CALCDENS(CRCH(IC,IR,MTDNCONC))
		IF(RECH(IC,IR).LT.0) DENSE=PS(IC,IR,IL)
C--SEAWAT:CONSERVE MASS
C		Q=RECH(IC,IR)
		Q=RECH(IC,IR)*DENSE
		QQ=Q
C
C4C-----ADD RECHARGE TO BUFFER.
C--SEAWAT: CONVERT TO VOLUMETRIC FLUX 
C		BUFF(IC,IR,IL)=Q
		BUFF(IC,IR,IL)=Q/DENSE
C
C4D-----IF RECHARGE IS POSITIVE ADD TO RATIN ELSE ADD IT TO RATOUT.
		IF(Q) 18,20,17
   17		RATIN=RATIN+QQ
		GO TO 20
   18		RATOUT=RATOUT-QQ
   20 CONTINUE
      GO TO 100
C
C5------OPTION=3; RECHARGE IS INTO HIGHEST CELL IN A VERTICAL COLUMN
C5------THAT IS NOT NO FLOW.  PROCESS HORIZONTAL CELL LOCATIONS ONE
C5------AT A TIME.
24    DO 30 IR=1,NROW
      DO 29 IC=1,NCOL
C
C5A-----INITIALIZE IRCH TO 1, AND LOOP THROUGH CELLS IN A VERTICAL
C5A-----COLUMN TO FIND WHERE TO PLACE RECHARGE.
		IRCH(IC,IR)=1
		DO 28 IL=1,NLAY
C
C5B-----IF CELL IS CONSTANT HEAD MOVE ON TO NEXT HORIZONTAL LOCATION.
			IF(IBOUND(IC,IR,IL).LT.0) GO TO 29
C
C5C-----IF CELL IS INACTIVE MOVE DOWN TO NEXT CELL.
			IF (IBOUND(IC,IR,IL).EQ.0) GO TO 28
C
C5D-----CELL IS VARIABLE HEAD, SO APPLY RECHARGE TO IT.  ADD RECHARGE TO
C5D-----BUFFER, AND STORE LAYER NUMBER IN IRCH.
C--SEAWAT: SET DENSE
			DENSE=DENSEREF
			IF(MTDNCONC.GT.0) DENSE=CALCDENS(CRCH(IC,IR,MTDNCONC))
			IF(RECH(IC,IR).LT.0) DENSE=PS(IC,IR,IL)
C--SEAWAT:CONSERVE MASS
C			Q=RECH(IC,IR)
			Q=RECH(IC,IR)*DENSE
			QQ=Q
C--SEAWAT:CONVERT TO VOLUMETRIC FLUX
C			BUFF(IC,IR,IL)=Q
			BUFF(IC,IR,IL)=Q/DENSE

			IRCH(IC,IR)=IL
C
C5E-----IF RECH IS POSITIVE ADD IT TO RATIN ELSE ADD IT TO RATOUT.
			IF(Q) 27,29,26
   26			RATIN=RATIN+QQ
			GO TO 29
   27			RATOUT=RATOUT-QQ
			GO TO 29
28		CONTINUE
29    CONTINUE
30    CONTINUE
C
C
C6------IF CELL-BY-CELL FLOW TERMS SHOULD BE SAVED, CALL APPROPRIATE
C6------UTILITY MODULE TO WRITE THEM.
100   IF(IBD.EQ.1) CALL UBUDSV(KSTP,KPER,TEXT,IRCHCB,BUFF,NCOL,NROW,
     1                          NLAY,IOUT)
      IF(IBD.EQ.2) CALL UBDSV3(KSTP,KPER,TEXT,IRCHCB,BUFF,IRCH,NRCHOP,
     1                   NCOL,NROW,NLAY,IOUT,DELT,PERTIM,TOTIM,IBOUND)
C
C7------MOVE TOTAL RECHARGE RATE INTO VBVL FOR PRINTING BY BAS1OT.
      ROUT=RATOUT
      RIN=RATIN
      VBVL(4,MSUM)=ROUT
      VBVL(3,MSUM)=RIN
C
C8------ADD RECHARGE FOR TIME STEP TO RECHARGE ACCUMULATOR IN VBVL.
      VBVL(2,MSUM)=VBVL(2,MSUM)+ROUT*DELT
      VBVL(1,MSUM)=VBVL(1,MSUM)+RIN*DELT
C
C9------MOVE BUDGET TERM LABELS TO VBNM FOR PRINT BY MODULE BAS_OT.
      VBNM(MSUM)=TEXT
C
C10-----INCREMENT BUDGET TERM COUNTER.
      MSUM=MSUM+1
C
C11-----RETURN
      RETURN
      END
