!The Polymorphic Tracking Code
!Copyright (C) Etienne Forest and Frank Schmidt
! See file A_SCRATCH_SIZE.F90

MODULE S_FAMILY
  USE S_FIBRE_BUNDLE
  IMPLICIT NONE

  ! LINKED LIST
  PRIVATE SURVEY_EXIST_PLANAR_L_NEW ,SURVEY_EXIST_PLANAR_IJ,MISALIGN_FIBRE_EQUAL,SURVEY_FIB ,SURVEY_EXIST_PLANAR_I
!,SURVEY_NO_PATCH
  PRIVATE COPY_LAYOUT,COPY_LAYOUT_I,KILL_PARA_L
  PRIVATE FIBRE_WORK,FIBRE_POL,FIBRE_BL,ADDP_ANBN,WORK_FIBRE,BL_FIBRE
  PRIVATE TRANS_D,COPY_LAYOUT_IJ,PUT_APERTURE_FIB,REMOVE_APERTURE_FIB


  INTERFACE EL_TO_ELP
     !LINKED
     MODULE PROCEDURE EL_TO_ELP_L
  END INTERFACE

  INTERFACE ELP_TO_EL
     !LINKED
     MODULE PROCEDURE ELP_TO_EL_L
  END INTERFACE

  INTERFACE SURVEY
     ! LINK LIST
     !     MODULE PROCEDURE SURVEY_NO_PATCH            ! NO PATCH
     MODULE PROCEDURE SURVEY_EXIST_PLANAR_L_NEW  ! ORDINARY SURVEY STARTING AT POSITION 1
     MODULE PROCEDURE SURVEY_FIB
     MODULE PROCEDURE SURVEY_EXIST_PLANAR_IJ
     MODULE PROCEDURE SURVEY_EXIST_PLANAR_I
11 END INTERFACE

  INTERFACE TRACK
     ! LINK LIST
     MODULE PROCEDURE SURVEY_FIB
     MODULE PROCEDURE SURVEY_EXIST_PLANAR_IJ
     MODULE PROCEDURE SURVEY_EXIST_PLANAR_I
  END INTERFACE

  INTERFACE KILL_PARA
     MODULE PROCEDURE KILL_PARA_L
  END INTERFACE

  INTERFACE ADD
     MODULE PROCEDURE ADDP_ANBN
  END INTERFACE

  INTERFACE PUT_APERTURE
     MODULE PROCEDURE PUT_APERTURE_FIB                               ! NEED UPGRADE
  END  INTERFACE

  INTERFACE REMOVE_APERTURE
     MODULE PROCEDURE REMOVE_APERTURE_FIB                               ! NEED UPGRADE
  END  INTERFACE



  INTERFACE ASSIGNMENT (=)
     ! LINKED
     MODULE PROCEDURE SCAN_FOR_POLYMORPHS
     MODULE PROCEDURE FIBRE_WORK
     MODULE PROCEDURE MISALIGN_FIBRE_EQUAL
     MODULE PROCEDURE FIBRE_POL
     MODULE PROCEDURE FIBRE_BL
     MODULE PROCEDURE BL_FIBRE
     MODULE PROCEDURE WORK_FIBRE
  END  INTERFACE

  INTERFACE EQUAL
     ! LINKED
     MODULE PROCEDURE COPY_LAYOUT
  END  INTERFACE

  INTERFACE COPY
     ! LINKED
     MODULE PROCEDURE COPY_LAYOUT_I
     MODULE PROCEDURE COPY_LAYOUT_IJ
  END  INTERFACE

  INTERFACE TRANS
     ! LINKED
     MODULE PROCEDURE TRANS_D
  END  INTERFACE

  INTERFACE TRANSLATE
     ! LINKED
     MODULE PROCEDURE TRANS_D
  END  INTERFACE

  INTERFACE ROTATE
     ! LINKED
     MODULE PROCEDURE ROT_LAYOUT
     MODULE PROCEDURE ROT_FIBRE
     MODULE PROCEDURE ROT_FRAME
  END  INTERFACE

  INTERFACE ROTATION
     ! LINKED
     MODULE PROCEDURE ROT_LAYOUT
     MODULE PROCEDURE ROT_FIBRE
     MODULE PROCEDURE ROT_FRAME
  END  INTERFACE



CONTAINS

  !NEW

  SUBROUTINE LOCATE_FIBRE(R,PIN,I)
    IMPLICIT NONE
    TYPE(LAYOUT), INTENT(IN) :: R
    TYPE(FIBRE), POINTER:: P,PIN
    INTEGER, INTENT(INOUT) :: I
    P=>R%START
    DO I=1,R%N
       IF(ASSOCIATED(PIN,P) ) EXIT
       P=>P%NEXT
    ENDDO
  END SUBROUTINE LOCATE_FIBRE

  SUBROUTINE GET_LENGTH(R,L)
    IMPLICIT NONE
    TYPE(LAYOUT), INTENT(IN) :: R
    REAL(DP), INTENT(OUT) :: L
    TYPE(FIBRE), POINTER:: P
    INTEGER I
    P=>R%START
    L=0.D0
    DO I=1,R%N
       L=L+P%MAG%P%LD
       P=>P%NEXT
    ENDDO
  END SUBROUTINE GET_LENGTH

  SUBROUTINE GET_FREQ(R,FREQ)
    IMPLICIT NONE
    TYPE(LAYOUT), INTENT(IN) :: R
    REAL(DP), INTENT(OUT) :: FREQ
    TYPE(FIBRE), POINTER:: P
    INTEGER I
    P=>R%START
    FREQ=0.D0
    DO I=1,R%N
       IF(ASSOCIATED(P%MAG%FREQ)) THEN
          IF(P%MAG%FREQ/=0.D0) THEN
             FREQ=P%MAG%FREQ
          ENDIF
       ENDIF
       P=>P%NEXT
    ENDDO
  END SUBROUTINE GET_FREQ

  SUBROUTINE GET_ALL(R,FREQ,VOLT,PHAS)
    IMPLICIT NONE
    TYPE(LAYOUT), INTENT(IN) :: R
    REAL(DP), INTENT(OUT) :: FREQ,VOLT,PHAS
    TYPE(FIBRE), POINTER:: P
    INTEGER I
    P=>R%START
    FREQ=0.D0;VOLT=0.D0;PHAS=0.D0;
    DO I=1,R%N
       IF(ASSOCIATED(P%MAG%FREQ)) THEN
          IF(P%MAG%FREQ/=0.D0) THEN
             FREQ=TWOPI*P%MAG%FREQ/CLIGHT
             VOLT=-P%MAG%VOLT*C_1D_3/P%MAG%P%P0C
             PHAS=P%MAG%PHAS
          ENDIF
       ENDIF
       P=>P%NEXT
    ENDDO
  END SUBROUTINE GET_ALL

  SUBROUTINE SET_FREQ(R,FREQ)
    IMPLICIT NONE
    TYPE(LAYOUT), INTENT(INOUT) :: R
    REAL(DP), INTENT(IN) :: FREQ
    TYPE(FIBRE), POINTER:: P
    INTEGER I
    P=>R%START
    DO I=1,R%N
       IF(ASSOCIATED(P%MAG%FREQ)) THEN
          IF(P%MAG%FREQ/=0.D0) THEN
             P%MAG%FREQ=FREQ
             P%MAGP%FREQ=FREQ
          ENDIF
       ENDIF
       P=>P%NEXT
    ENDDO
  END SUBROUTINE SET_FREQ

  SUBROUTINE ADD_FREQ(R,FREQ)
    IMPLICIT NONE
    TYPE(LAYOUT), INTENT(INOUT) :: R
    REAL(DP), INTENT(IN) :: FREQ
    TYPE(FIBRE), POINTER:: P
    INTEGER I
    P=>R%START
    DO I=1,R%N
       IF(ASSOCIATED(P%MAG%FREQ)) THEN
          IF(P%MAG%FREQ/=0.D0) THEN
             P%MAG%FREQ=P%MAG%FREQ+FREQ
             P%MAGP%FREQ=P%MAGP%FREQ+FREQ
          ENDIF
       ENDIF
       P=>P%NEXT
    ENDDO
  END SUBROUTINE ADD_FREQ

  !END NEW
  SUBROUTINE ADDP_ANBN(EL,NM,F,V) ! EXTENDS THE ADD ROUTINES FROM THE ELEMENT(P) TO THE FIBRE
    IMPLICIT NONE
    TYPE(FIBRE), INTENT(INOUT) ::EL
    REAL(DP), INTENT(IN) ::V
    INTEGER, INTENT(IN) ::NM,F

    CALL ADD(EL%MAG,NM,F,V)
    CALL ADD(EL%MAGP,NM,F,V)

  END SUBROUTINE ADDP_ANBN


  SUBROUTINE PUT_APERTURE_FIB(EL,KIND,R,X,Y)
    IMPLICIT NONE
    REAL(DP),INTENT(IN):: R(:),X,Y
    INTEGER,INTENT(IN):: KIND
    TYPE(FIBRE),INTENT(INOUT):: EL

    CALL PUT_APERTURE(EL%MAG,KIND,R,X,Y)
    CALL PUT_APERTURE(EL%MAGP,KIND,R,X,Y)

  END  SUBROUTINE PUT_APERTURE_FIB

  SUBROUTINE REMOVE_APERTURE_FIB(EL)
    IMPLICIT NONE
    TYPE(FIBRE),INTENT(INOUT):: EL

    CALL REMOVE_APERTURE_EL(EL%MAG)
    CALL REMOVE_APERTURE_ELP(EL%MAGP)

  END  SUBROUTINE REMOVE_APERTURE_FIB


  SUBROUTINE  FIBRE_WORK(S2,S1) ! CHANGES THE ENERGY OF THE FIBRE AND TURNS THE ENERGY PATCH ON
    IMPLICIT NONE
    TYPE (WORK),INTENT(IN):: S1
    TYPE(FIBRE),INTENT(INOUT):: S2

    S2%MAG=S1
    S2%MAGP=S1
    ! S2%PATCH%ENERGY=.TRUE.

  END SUBROUTINE FIBRE_WORK

  SUBROUTINE  WORK_FIBRE(S2,S1)  ! SUCKS THE ENERGY OUT OF A FIBRE BY LOKING AT ELEMENT
    IMPLICIT NONE
    TYPE (FIBRE),INTENT(IN):: S1
    TYPE(WORK),INTENT(INOUT):: S2

    S2=S1%MAG
    IF(ABS(S1%MAG%P%P0C-S1%MAGP%P%P0C)>C_1D_10) THEN
       W_P=0
       W_P%NC=3
       W_P%FC='(2(1X,A72,/),(1X,A72))'
       W_P%C(1)=" BEWARE : ELEMENT AND ELEMENTP SEEM TO HAVE "
       W_P%C(2)=" DIFFERENT REFERENCE ENERGIES!"
       WRITE(W_P%C(3),'(1X,G20.14,1X,G20.14)')  S1%MAG%P%P0C,S1%MAGP%P%P0C
       CALL WRITE_E(100)
    ENDIF

  END SUBROUTINE WORK_FIBRE

  SUBROUTINE  MISALIGN_FIBRE_EQUAL(S2,S1) ! MISALIGNS FULL FIBRE; FILLS IN CHART AND MAGNET_CHART
    IMPLICIT NONE
    REAL(DP),INTENT(IN):: S1(6)
    TYPE(FIBRE),INTENT(INOUT):: S2

    CALL MISALIGN_FIBRE(S2,S1)

  END SUBROUTINE  MISALIGN_FIBRE_EQUAL


  SUBROUTINE  MISALIGN_FIBRE(S2,S1,OMEGA,BASIS) ! MISALIGNS FULL FIBRE; FILLS IN CHART AND MAGNET_CHART
    IMPLICIT NONE
    REAL(DP),INTENT(IN):: S1(6)
    REAL(DP), OPTIONAL, INTENT(IN) :: OMEGA(3),BASIS(3,3)
    TYPE(FIBRE),INTENT(INOUT):: S2
    REAL(DP) ANGLE(3),T_GLOBAL(3)
    TYPE(MAGNET_FRAME), POINTER :: F,F0,F_BASIS
    TYPE(MAGNET_FRAME),  POINTER :: FAKE
    REAL(DP) D_IN(3),D_OUT(3),OMEGAT(3),BASIST(3,3)
    INTEGER I

    CALL ALLOC(FAKE)

    FAKE%ENT=GLOBAL_FRAME
    FAKE%MID=GLOBAL_FRAME
    FAKE%EXI=GLOBAL_FRAME
    FAKE%A=GLOBAL_ORIGIN
    FAKE%O=GLOBAL_ORIGIN
    FAKE%B=GLOBAL_ORIGIN



    IF(ASSOCIATED(S2%CHART)) THEN
       IF(.NOT.ASSOCIATED(S2%MAG%D) ) ALLOCATE(S2%MAG%D(3))
       IF(.NOT.ASSOCIATED(S2%MAG%R) ) ALLOCATE(S2%MAG%R(3))
       IF(.NOT.ASSOCIATED(S2%MAGP%D)) ALLOCATE(S2%MAGP%D(3))
       IF(.NOT.ASSOCIATED(S2%MAGP%R)) ALLOCATE(S2%MAGP%R(3))
       DO I=1,3
          S2%MAG%D(I)=S1(I);   S2%MAGP%D(I)=S1(I);
          S2%MAG%R(I)=S1(3+I); S2%MAGP%R(I)=S1(3+I);
       ENDDO
       S2%CHART%D_IN=0.0_DP;S2%CHART%D_OUT=0.0_DP;
       S2%CHART%ANG_IN=0.0_DP;S2%CHART%ANG_OUT=0.0_DP;
       S2%MAG%MIS=.TRUE.
       S2%MAGP%MIS=.TRUE.

       ! ADD CODE HERE
       CALL ALLOC(F)
       CALL ALLOC(F0)
       CALL SURVEY_NO_PATCH(S2,FAKE=FAKE,MAGNETFRAME=F)
       ! MOVE THE ORIGINAL INTERNAL CHART F
       F0=F
       ANGLE=S2%MAG%R
       IF(PRESENT(BASIS)) THEN
          BASIST=BASIS
       ELSE
          BASIST=F0%MID
       ENDIF
       IF(PRESENT(OMEGA)) THEN
          OMEGAT=OMEGA
       ELSE
          OMEGAT=F0%O
       ENDIF

       CALL ROT_FRAME(F,OMEGAT,ANGLE,1,BASIS=BASIST)

       IF(PRESENT(BASIS)) THEN   ! MUST ROTATE THAT FRAME AS WELL FOR CONSISTENCY IN DEFINITION WHAT A MISALIGNMENT IS IN PTC
          CALL   GEO_ROT(BASIST,ANGLE,1)
       ELSE
          BASIST=F%MID    ! ALREADY ROTATED
       ENDIF

       CALL CHANGE_BASIS(S2%MAG%D,BASIST,T_GLOBAL,GLOBAL_FRAME)


       F%A=F%A+T_GLOBAL
       F%O=F%O+T_GLOBAL
       F%B=F%B+T_GLOBAL






       CALL COMPUTE_ENTRANCE_ANGLE(F0%ENT,F%ENT,S2%CHART%ANG_IN)
       CALL COMPUTE_ENTRANCE_ANGLE(F%EXI,F0%EXI,S2%CHART%ANG_OUT)

       D_IN=F%A-F0%A
       D_OUT=F0%B-F%B

       !        WRITE(6,*) " IN GLOBAL BASIS D_IN AND D_OUT"

       !        WRITE(6,*) D_IN
       !        WRITE(6,*) D_OUT

       CALL CHANGE_BASIS(D_IN,GLOBAL_FRAME,S2%CHART%D_IN,F%ENT)
       CALL CHANGE_BASIS(D_OUT,GLOBAL_FRAME,S2%CHART%D_OUT,F0%EXI)

       !        WRITE(6,*) " IN LOCAL  BASIS D_IN AND D_OUT AS WELL AS ANGLES"
       !       WRITE(6,*) " ***************************************"
       !      WRITE(6,*) S2%CHART%ANG_IN
       !      WRITE(6,*) S2%CHART%ANG_OUT
       !      WRITE(6,*) S2%CHART%D_IN
       !      WRITE(6,*) S2%CHART%D_OUT

       !      WRITE(6,*) " ***************************************"

       CALL KILL(F)
       CALL KILL(F0)
       CALL SURVEY_NO_PATCH(S2,FAKE=FAKE)
    ELSE
       W_P=0
       W_P%NC=1
       W_P%FC='((1X,A72))'
       WRITE(W_P%C(1),'(1X,A39,1X,A16)') " CANNOT MISALIGN THIS FIBRE: NO CHARTS ", S2%MAG%NAME
       CALL WRITE_E(100)
    ENDIF
    CALL KILL(FAKE)
  END SUBROUTINE MISALIGN_FIBRE

  SUBROUTINE  MAD_MISALIGN_FIBRE(S2,S1) ! MISALIGNS FULL FIBRE; FILLS IN CHART AND MAGNET_CHART
    IMPLICIT NONE
    REAL(DP),INTENT(IN):: S1(6)
    TYPE(FIBRE),INTENT(INOUT):: S2
    REAL(DP) ENT(3,3),T(3),MAD_ANGLE(3),T_GLOBAL(3),ANGLE(3),MIS(6)
    ent=S2%CHART%F%ent
    T(1)=S1(1);T(2)=S1(2);T(3)=S1(3);
    MAD_ANGLE(1)=-S1(4)
    MAD_ANGLE(2)=-S1(5)
    MAD_ANGLE(3)=S1(6)

    CALL CHANGE_BASIS(T,ENT,T_GLOBAL,GLOBAL_FRAME)
    ANGLE=ZERO; ANGLE(3)=MAD_ANGLE(3)
    CALL GEO_ROT(ENT,ENT,ANGLE,ENT)
    ANGLE=ZERO; ANGLE(1)=MAD_ANGLE(1)
    CALL GEO_ROT(ENT,ENT,ANGLE,ENT)
    ANGLE=ZERO; ANGLE(2)=MAD_ANGLE(2)
    CALL GEO_ROT(ENT,ENT,ANGLE,ENT)

    CALL CHANGE_BASIS(T_GLOBAL,GLOBAL_FRAME,T,ENT)
    CALL COMPUTE_ENTRANCE_ANGLE(S2%CHART%F%ent,ENT,ANGLE)
    MIS(1:3)=T
    MIS(4:6)=ANGLE
    call MISALIGN_FIBRE(S2,MIS,S2%CHART%F%A,S2%CHART%F%ent)

  END SUBROUTINE MAD_MISALIGN_FIBRE

  ! NEW ROUTINES TO CHANGE LAYOUT

  SUBROUTINE  TRANS_D(R,D,I1,I2,ORDER,BASIS) ! TRANSLATES A LAYOUT
    IMPLICIT NONE
    TYPE (LAYOUT),INTENT(INOUT):: R
    REAL(DP),INTENT(IN):: D(3)
    REAL(DP), OPTIONAL :: BASIS(3,3)
    TYPE(FIBRE), POINTER::P
    INTEGER I,I11,I22,J
    INTEGER, OPTIONAL, INTENT(IN) :: ORDER,I1,I2
    ! THIS ROUTINE TRANSLATE THE ENTIRE LINE BY A(3) IN STANDARD ORDER USING THE
    ! GLOBAL FRAME TO DEFINE D

    P=>R%START

    I11=1
    I22=R%N
    IF(PRESENT(I1))  I11=I1
    IF(PRESENT(I2))  I22=I2
    DO I=1,I11-1
       P=>P%NEXT
    ENDDO


    DO I=1,I22-I11+1
       CALL TRANS_F(P,D,ORDER,BASIS)
       P=>P%NEXT
    ENDDO


  END SUBROUTINE TRANS_D

  SUBROUTINE  TRANS_F(R,D,ORDER,BASIS) ! TRANSLATES A LAYOUT
    IMPLICIT NONE
    TYPE (FIBRE),TARGET,INTENT(INOUT):: R
    REAL(DP),INTENT(IN):: D(3)
    REAL(DP), OPTIONAL :: BASIS(3,3)
    TYPE(FIBRE), POINTER::P
    INTEGER I,IORDER,I11,I22,J
    INTEGER, OPTIONAL, INTENT(IN) :: ORDER
    REAL(DP) DD(3)
    ! THIS ROUTINE TRANSLATE THE ENTIRE LINE BY A(3) IN STANDARD ORDER USING THE
    ! GLOBAL FRAME TO DEFINE D

    P=>R

    IORDER=1
    DD=D
    IF(PRESENT(ORDER)) IORDER=ORDER
    IF(PRESENT(BASIS)) THEN
       CALL CHANGE_BASIS(D,BASIS,DD,GLOBAL_FRAME)
    ENDIF



    IF(.NOT.ASSOCIATED(P%PARENT_CHART)) THEN  ! ONLY TRANSLATES ORIGINAL OTHERWISE
       ! THEY WILL TRANSLATE MORE THAN ONCE

       IF(ASSOCIATED(P%CHART)) THEN
          IF(ASSOCIATED(P%CHART%F)) THEN
             CALL TRANS_FRAME(P%CHART%F,D,ORDER,BASIS)

             IF(ASSOCIATED(P%MAG%P%F)) THEN
                CALL TRANS_FRAME(P%MAG%P%F,D,ORDER,BASIS)
                P%MAGP%P%F=P%MAG%P%F
             ENDIF
          ENDIF
       ENDIF

    ENDIF


  END SUBROUTINE TRANS_F


  SUBROUTINE  TRANS_FRAME(R,D,ORDER,BASIS) ! TRANSLATES A LAYOUT
    IMPLICIT NONE
    TYPE (MAGNET_FRAME),TARGET, INTENT(INOUT):: R
    REAL(DP),INTENT(IN):: D(3)
    REAL(DP), OPTIONAL :: BASIS(3,3)
    INTEGER I,IORDER,I11,I22,J
    INTEGER, OPTIONAL, INTENT(IN) :: ORDER
    REAL(DP) DD(3)
    TYPE(MAGNET_FRAME), POINTER :: P
    ! THIS ROUTINE TRANSLATE THE ENTIRE LINE BY A(3) IN STANDARD ORDER USING THE
    ! GLOBAL FRAME TO DEFINE D

    P=>R

    IORDER=1
    DD=D
    IF(PRESENT(ORDER)) IORDER=ORDER
    IF(PRESENT(BASIS)) THEN
       CALL CHANGE_BASIS(D,BASIS,DD,GLOBAL_FRAME)
    ENDIF



    P%A=P%A+IORDER*DD
    P%B=P%B+IORDER*DD
    P%O=P%O+IORDER*DD



  END SUBROUTINE TRANS_FRAME


  SUBROUTINE  ROT_LAYOUT(R,OMEGA,Ang,I1,I2,ORDER,BASIS) ! ROTATES A LAYOUT AROUND OMEGA BY A(3)  IN STANDARD PTC ORDER
    ! INVERSE => ORDER=-1   USING GLOBAL FRAME
    IMPLICIT NONE
    TYPE (LAYOUT),INTENT(INOUT):: R
    REAL(DP),INTENT(IN):: OMEGA(3),Ang(3)
    TYPE(FIBRE), POINTER::P
    REAL(DP) D(3),OMEGAT(3)
    INTEGER I,IORDER,I11,I22,J
    INTEGER, OPTIONAL :: ORDER,I1,I2
    REAL(DP), OPTIONAL, INTENT(IN):: BASIS(3,3)
    real(dp) basist(3,3)
    ! THIS ROUTINE ROTATES THE ENTIRE LINE BY A(3) IN STANDARD ORDER USING THE
    ! GLOBAL FRAME TO DEFINE THE ANGLES A(3) AND THE POINT OMEGA AROUND WHICH THE
    ! ROTATION HAPPENS
    ! OMEGA DEFINED IN THAT BASIS
    ! ANGLE AS WELL
    OMEGAT=OMEGA
    P=>R%START
    IORDER=1
    I11=1
    I22=R%N
    IF(PRESENT(ORDER)) IORDER=ORDER
    IF(PRESENT(I1))  I11=I1
    IF(PRESENT(I2))  I22=I2

    BASIST=GLOBAL_FRAME            ! NECESSARY SINCE BASIS CAN CHANGE DURING THE CALCULATION ASSUMING A POINTER IS PASSED
    IF(PRESENT(BASIS)) BASIST=BASIS


    DO I=1,I11-1
       P=>P%NEXT
    ENDDO


    DO I=1,I22-I11+1
       CALL ROT_FIBRE(P,OMEGA,Ang,ORDER,BASIST)
       P=>P%NEXT
    ENDDO

  END SUBROUTINE ROT_LAYOUT

  SUBROUTINE  ROT_FIBRE(R,OMEGA,Ang,ORDER,BASIS) ! ROTATES A FIBRE AROUND OMEGA BY A(3)  IN STANDARD PTC ORDER
    ! INVERSE => ORDER=-1   USING GLOBAL FRAME
    IMPLICIT NONE
    TYPE (FIBRE),TARGET,INTENT(INOUT):: R
    REAL(DP),INTENT(IN):: OMEGA(3),Ang(3)
    TYPE(FIBRE), POINTER::P
    REAL(DP) D(3),OMEGAT(3)
    INTEGER I,IORDER,I11,I22,J
    INTEGER, OPTIONAL :: ORDER
    REAL(DP), OPTIONAL, INTENT(IN):: BASIS(3,3)
    real(dp) basist(3,3)
    ! THIS ROUTINE ROTATES THE ENTIRE LINE BY A(3) IN STANDARD ORDER USING THE
    ! GLOBAL FRAME TO DEFINE THE ANGLES A(3) AND THE POINT OMEGA AROUND WHICH THE
    ! ROTATION HAPPENS
    ! OMEGA DEFINED IN THAT BASIS
    ! ANGLE AS WELL
    OMEGAT=OMEGA
    P=>R
    IORDER=1
    IF(PRESENT(ORDER)) IORDER=ORDER
    BASIST=GLOBAL_FRAME            ! NECESSARY SINCE BASIS CAN CHANGE DURING THE CALCULATION ASSUMING A POINTER IS PASSED
    IF(PRESENT(BASIS)) BASIST=BASIS




    IF(.NOT.ASSOCIATED(P%PARENT_CHART)) THEN  ! ONLY ROTATES ORIGINAL OTHERWISE
       IF(ASSOCIATED(P%CHART)) THEN
          IF(ASSOCIATED(P%CHART%F)) THEN
             ! THEY WILL ROTATE MORE THAN ONCE
             CALL ROT_FRAME(P%CHART%F, OMEGAT,Ang,IORDER,BASIST)


             IF(ASSOCIATED(P%MAG%P%F)) THEN

                CALL ROT_FRAME(P%MAG%P%F, OMEGAT,Ang,IORDER,BASIST)
                P%MAGP%P%F=P%MAG%P%F
             ENDIF
          ENDIF
       ENDIF
    ENDIF


  END SUBROUTINE ROT_FIBRE






  SUBROUTINE  FIBRE_BL(S2,S1) ! PUTS A NEW MULTIPOLE BLOCK INTO FIBRE. EXTENDS ELEMENT(P) ROUTINES TO FIBRES
    IMPLICIT NONE
    TYPE (MUL_BLOCK),INTENT(IN):: S1
    TYPE(FIBRE),INTENT(INOUT):: S2

    S2%MAG=S1
    S2%MAGP=S1

  END   SUBROUTINE  FIBRE_BL

  SUBROUTINE  BL_FIBRE(S2,S1) ! SUCKS THE MULTIPOLE OUT LOOKING AT ELEMENT
    IMPLICIT NONE
    TYPE (FIBRE),INTENT(IN):: S1
    TYPE(MUL_BLOCK),INTENT(INOUT):: S2

    S2=S1%MAG


  END   SUBROUTINE  BL_FIBRE


  SUBROUTINE SURVEY_EXIST_PLANAR_IJ(PLAN,I1,I2,ENT,A) ! STANDARD SURVEY FROM FIBRE #I1 TO #I2
    IMPLICIT NONE
    TYPE(LAYOUT), INTENT(INOUT):: PLAN
    TYPE (FIBRE), POINTER :: C
    TYPE (PATCH), POINTER :: P
    REAL(DP),OPTIONAL, INTENT(INOUT) :: A(3),ENT(3,3)
    INTEGER , INTENT(IN)::I1,I2
    INTEGER I
    REAL(DP) ANG(3),TRA(3),D(3)
    LOGICAL(LP) SEL
    REAL(DP) AT(3),ENTT(3,3),NORM


    NULLIFY(C);

    CALL MOVE_TO(PLAN,C,MOD_N(I1,PLAN%N))


    IF((PRESENT(ENT).AND.(.NOT.PRESENT(A))).OR.(PRESENT(A).AND.(.NOT.PRESENT(ENT)))) THEN
       W_P=0
       W_P%NC=2
       W_P%FC='(2(1X,A72,/),(1X,A72))'
       W_P%C(1)=" BEWARE : ENT AND A  "
       W_P%C(2)=" MUST BOTH BE PRESENT OR ABSENT"
       CALL WRITE_E(100)
    ELSEIF(PRESENT(ENT)) THEN
       ENTT=ENT
       AT=A
    ELSE
       IF(ASSOCIATED(C%CHART%F)) THEN
          IF(C%DIR==1) THEN
             ENTT=C%CHART%F%ENT
             AT=C%CHART%F%A
          ELSE
             ENTT=C%CHART%F%EXI
             AT=C%CHART%F%B
          ENDIF
       ELSE
          write(6,*) " No charts "
          STOP 888
       ENDIF
       IF(ASSOCIATED(C%PATCH)) THEN
          P=>C%PATCH
          IF(P%PATCH) THEN
             NORM=ZERO
             DO I=1,3
                NORM=NORM+ABS(P%A_ANG(I))
                NORM=NORM+ABS(P%A_D(I))
             ENDDO
             NORM=NORM+ABS(P%A_YZ-1)+ABS(P%A_XZ-1)
             IF(NORM/=ZERO) THEN
                W_P=0
                W_P%NC=3
                W_P%FC='(2(1X,A72,/),(1X,A72))'
                W_P%C(1)=" THERE IS A FRONTAL PATCH IN FIRST FIBRE OF THE SURVEY"
                W_P%C(2)=" AND THAT PATCH IS NOT IDENTITY. ITS NORM IS:"
                WRITE(W_P%C(3),'(1X,G20.14)')  NORM
                CALL WRITE_E(100)
             ENDIF
          ENDIF
       ENDIF

    ENDIF



    I=I1

    DO  WHILE(I<I2.AND.ASSOCIATED(C))

       CALL TRACK(C,ENTT,AT)

       C=>C%NEXT
       I=I+1
    ENDDO


    IF(PRESENT(ENT)) THEN
       ENT=ENTT
       A=AT
    ENDIF
    !   DO I=I1,I2

    !    CALL TRACK(C,ENTT,AT)
    !      C=>C%NEXT
    !   ENDDO



  END SUBROUTINE SURVEY_EXIST_PLANAR_IJ


  SUBROUTINE SURVEY_FIB(C,ENT,A,MAGNETFRAME,E_IN)
! SURVEYS A SINGLE ELEMENT FILLS IN CHART AND MAGNET_CHART; LOCATES ORIGIN AT THE ENTRANCE OR EXIT
    IMPLICIT NONE
    TYPE(FIBRE), TARGET , INTENT(INOUT):: C
    TYPE (CHART), POINTER :: CL
    TYPE(MAGNET_FRAME), OPTIONAL :: MAGNETFRAME
    TYPE(MAGNET_FRAME), POINTER :: FAKE
    TYPE(INNER_FRAME), OPTIONAL :: E_IN
    REAL(DP), INTENT(INOUT)  :: ENT(3,3),A(3)
    REAL(DP) D(3),ANG(3)
    INTEGER I
    LOGICAL(LP) SEL
    TYPE (PATCH), POINTER :: P

    NULLIFY(FAKE)
    IF(PRESENT(E_IN) ) CALL XFRAME(E_IN,ENT,A,-6)
    IF(PRESENT(E_IN) ) CALL XFRAME(E_IN,ENT,A,-5)

    SEL=.FALSE.
    IF(ASSOCIATED(C%CHART)) THEN
       SEL=.FALSE.
       IF(ASSOCIATED(C%CHART%F)) SEL=.TRUE.
    ENDIF

    !        IF(.NOT.SEL) THEN !
    CALL ALLOC(FAKE)
    !        ENDIF

    IF(ASSOCIATED(C%PATCH)) THEN
       P=>C%PATCH
       IF(P%PATCH) THEN
          ANG=ZERO
          ANG=P%A_ANG ; IF(P%A_YZ<0) ANG(1)=ANG(1)+PI ; IF(P%A_XZ<0) ANG(2)=ANG(2)+PI ;
          D=ZERO
          CALL GEO_ROT(ENT,D,ANG,1,ENT)

          CALL GEO_TRA(A,ENT,P%A_D,1)

       ENDIF
    ENDIF

    IF(PRESENT(E_IN) ) CALL XFRAME(E_IN,ENT,A,-4)
    IF(PRESENT(E_IN) ) CALL XFRAME(E_IN,ENT,A,-3)

    IF(SEL) THEN
       IF(C%DIR==1) THEN
          C%CHART%F%ENT=ENT
          C%CHART%F%A=A
       ELSE
          C%CHART%F%EXI=ENT
          C%CHART%F%B=A
       ENDIF
    ELSE
       IF(C%DIR==1) THEN
          FAKE%ENT=ENT
          FAKE%A=A
       ELSE
          FAKE%EXI=ENT
          FAKE%B=A
       ENDIF
    ENDIF


    CALL SURVEY_NO_PATCH(C,FAKE=FAKE,E_IN=E_IN)


    IF(SEL) THEN
       IF(C%DIR==1) THEN
          ENT=C%CHART%F%EXI
          A=C%CHART%F%B
       ELSE
          ENT=C%CHART%F%ENT
          A=C%CHART%F%A
       ENDIF
    ELSE
       IF(C%DIR==1) THEN
          ENT=FAKE%EXI
          A=FAKE%B
       ELSE
          ENT=FAKE%ENT
          A=FAKE%A
       ENDIF
    ENDIF

    IF(PRESENT(E_IN) ) CALL XFRAME(E_IN,ENT,A,E_IN%NST-3)
    IF(PRESENT(E_IN) ) CALL XFRAME(E_IN,ENT,A,E_IN%NST-2)


    IF(ASSOCIATED(C%PATCH)) THEN
       IF(P%PATCH) THEN
          ANG=ZERO
          ANG=P%B_ANG ; IF(P%B_YZ<0) ANG(1)=ANG(1)+PI ; IF(P%B_XZ<0) ANG(2)=ANG(2)+PI ;
          D=ZERO
          CALL GEO_ROT(ENT,D,ANG,1,ENT)

          CALL GEO_TRA(A,ENT,P%B_D,1)

       ENDIF
    ENDIF
    IF(PRESENT(E_IN) ) CALL XFRAME(E_IN,ENT,A,E_IN%NST-1)
    IF(PRESENT(E_IN) ) CALL XFRAME(E_IN,ENT,A,E_IN%NST)
    IF(PRESENT(E_IN) ) CALL XFRAME(E_IN,ENT,A,-7)

    !        IF(.NOT.SEL) THEN
    CALL KILL(FAKE)
    !        ENDIF

  END SUBROUTINE SURVEY_FIB





  SUBROUTINE SURVEY_EXIST_PLANAR_L_NEW(PLAN,ENT,A) ! CALLS ABOVE ROUTINE FROM FIBRE #1 TO #PLAN%N : STANDARD SURVEY
    IMPLICIT NONE
    TYPE(LAYOUT), INTENT(INOUT):: PLAN
    REAL(DP),OPTIONAL, INTENT(INOUT) :: A(3),ENT(3,3)

    CALL TRACK(PLAN,1,ENT,A)

  END SUBROUTINE SURVEY_EXIST_PLANAR_L_NEW

  SUBROUTINE SURVEY_EXIST_PLANAR_I(PLAN,I1,ENT,A) ! STANDARD SURVEY FROM FIBRE #I1 TO #I2
    IMPLICIT NONE
    TYPE(LAYOUT), INTENT(INOUT):: PLAN
    REAL(DP),OPTIONAL, INTENT(INOUT) :: A(3),ENT(3,3)
    INTEGER , INTENT(IN)::I1
    INTEGER I2
    I2=PLAN%N+I1

    CALL TRACK(PLAN,I1,I2,ENT,A)

  END SUBROUTINE SURVEY_EXIST_PLANAR_I

  SUBROUTINE SURVEY_NO_PATCH(C,FAKE,MAGNETFRAME,E_IN)
! SURVEYS A SINGLE ELEMENT FILLS IN CHART AND MAGNET_CHART; LOCATES ORIGIN AT THE ENTRANCE OR EXIT
    IMPLICIT NONE
    TYPE(FIBRE), TARGET , INTENT(INOUT):: C
    TYPE (CHART), POINTER :: CL
    TYPE(MAGNET_FRAME), OPTIONAL :: FAKE,MAGNETFRAME
    TYPE(INNER_FRAME), OPTIONAL :: E_IN
    TYPE(MAGNET_FRAME), POINTER :: F
    REAL(DP) ENT(3,3),EXI(3,3),HA,D(3),A(3)
    INTEGER I
    TYPE (CHART) C_FAKE
    LOGICAL(LP) WITH_EXTERNAL_FRAME_TEMP,SEL

    IF(.NOT.ASSOCIATED(C%CHART).AND.(.NOT.PRESENT(FAKE))) THEN
       RETURN
    ENDIF

    WITH_EXTERNAL_FRAME_TEMP=WITH_EXTERNAL_FRAME
    WITH_EXTERNAL_FRAME=.TRUE.

    SEL=.FALSE.
    IF(ASSOCIATED(C%CHART)) THEN
       SEL=.FALSE.
       IF(ASSOCIATED(C%CHART%F)) SEL=.TRUE.
    ENDIF


    IF(SEL) THEN
       CALL TRACK(C%CHART,C%MAG,C%DIR,MAGNETFRAME,E_IN)
    ELSE
       C_FAKE=1
       C_FAKE%F=FAKE
       CALL TRACK(C_FAKE,C%MAG,C%DIR,MAGNETFRAME,E_IN)
       FAKE=C_FAKE%F

       C_FAKE=-1
    ENDIF

    IF(ASSOCIATED(C%MAGP%P%F)) THEN
       C%MAGP%P%F=C%MAG%P%F
    ENDIF

    WITH_EXTERNAL_FRAME=WITH_EXTERNAL_FRAME_TEMP

    RETURN

  END SUBROUTINE SURVEY_NO_PATCH




  SUBROUTINE COPY_LAYOUT(R2,R1) ! COPY STANDARD LAYOUT ONLY
    IMPLICIT  NONE
    TYPE(LAYOUT), INTENT(INOUT):: R1
    TYPE(LAYOUT), INTENT(INOUT):: R2
    TYPE (FIBRE), POINTER :: C
    LOGICAL(LP) DONEIT
    LOGICAL(LP) :: DONEITT=.TRUE.
    NULLIFY(C)

    CALL LINE_L(R1,DONEIT)


    IF(ASSOCIATED(R2%N)) CALL KILL(R2)
    CALL SET_UP(R2)

    R2%CLOSED=.FALSE.
    R2%NTHIN=R1%NTHIN
    R2%THIN=R1%THIN

    C=> R1%START
    DO WHILE(ASSOCIATED(C))
       CALL APPEND(R2,C)
       C=>C%NEXT
    ENDDO
    R2%LASTPOS=R2%N
    R2%LAST=>R2%END

    R2%CLOSED=R1%CLOSED
    CALL RING_L(R2,DONEITT)
    CALL RING_L(R1,DONEIT)

  END SUBROUTINE COPY_LAYOUT

  SUBROUTINE COPY_LAYOUT_IJ(R1,I,J,R2)  ! COPY PIECES OF A STANDARD LAYOUT FROM FIBRE #I TO #J
    IMPLICIT  NONE
    TYPE(LAYOUT), INTENT(INOUT):: R1
    TYPE(LAYOUT), INTENT(INOUT):: R2
    INTEGER, INTENT(IN):: I,J
    TYPE (FIBRE), POINTER :: C
    LOGICAL(LP) DONEIT
    LOGICAL(LP) :: DONEITT=.TRUE.
    INTEGER K
    NULLIFY(C)

    CALL LINE_L(R1,DONEIT)


    IF(ASSOCIATED(R2%N)) CALL KILL(R2)
    CALL SET_UP(R2)

    R2%CLOSED=.FALSE.
    R2%NTHIN=R1%NTHIN
    R2%THIN=R1%THIN

    CALL MOVE_TO(R1,C,I)
    K=I
    DO WHILE(ASSOCIATED(C).AND.K<=J)
       CALL APPEND(R2,C)
       !    CALL APPEND(R2,C%MAG)
       !    CALL EQUAL(R2%END%CHART,C%CHART)
       C=>C%NEXT
       K=K+1
    ENDDO
    R2%LASTPOS=R2%N
    R2%LAST=>R2%END

    R2%CLOSED=R1%CLOSED
    CALL RING_L(R2,DONEITT)
    CALL RING_L(R1,DONEIT)

  END SUBROUTINE COPY_LAYOUT_IJ




  SUBROUTINE COPY_LAYOUT_I(R1,R2) ! COPIES IN THE COPY ORDER RATHER THAN THE LAYOUT ORDER
    IMPLICIT  NONE
    TYPE(LAYOUT), INTENT(INOUT):: R1
    TYPE(LAYOUT), INTENT(INOUT):: R2

    CALL EQUAL(R2,R1)

  END SUBROUTINE COPY_LAYOUT_I

  SUBROUTINE KILL_PARA_L(R)  ! RESETS ALL THE PARAMETERS IN A LAYOUT : REMOVE POLYMORPHIC KNOBS
    IMPLICIT NONE
    TYPE(LAYOUT),INTENT(INOUT):: R
    TYPE (FIBRE), POINTER :: C
    LOGICAL(LP) DONEIT

    NULLIFY(C)

    CALL LINE_L(R,DONEIT)

    C=>R%START

    DO WHILE(ASSOCIATED(C))
       CALL RESET31(C%MAGP)
       C=>C%NEXT
    ENDDO
    CALL RING_L(R,DONEIT)
  END       SUBROUTINE KILL_PARA_L

  SUBROUTINE  FIBRE_POL(S2,S1)    !  SET POLYMORPH IN A FIBRE UNCONDITIONALLY
    IMPLICIT NONE
    TYPE (POL_BLOCK),INTENT(IN):: S1
    TYPE(FIBRE),INTENT(INOUT):: S2
    S2%MAGP=S1
  END SUBROUTINE  FIBRE_POL

  SUBROUTINE SCAN_FOR_POLYMORPHS(R,B)   !  SET POLYMORPH IN A FULL LAYOUT ONLY IF THE MAGNET IS A PRIMITIVE PARENT
    IMPLICIT  NONE
    TYPE(LAYOUT), INTENT(INOUT):: R
    TYPE(POL_BLOCK), INTENT(IN):: B

    TYPE (FIBRE), POINTER :: C
    LOGICAL(LP) DONEIT

    NULLIFY(C)
    CALL LINE_L(R,DONEIT)
    C=>R%START

    DO WHILE(ASSOCIATED(C))
       IF(.NOT.ASSOCIATED(C%PARENT_MAG)) THEN
          C%MAGP=B
       ENDIF
       C=>C%NEXT
    ENDDO
    CALL RING_L(R,DONEIT)

  END SUBROUTINE SCAN_FOR_POLYMORPHS

  SUBROUTINE EL_TO_ELP_L(R)  ! COPY ALL PRIMITIVES ELEMENT INTO ELEMENTP
    IMPLICIT  NONE
    TYPE(LAYOUT), INTENT(INOUT):: R
    TYPE (FIBRE), POINTER :: C
    LOGICAL(LP) DONEIT
    NULLIFY(C)
    CALL LINE_L(R,DONEIT)

    C=>R%START
    DO   WHILE(ASSOCIATED(C))
       IF(.NOT.ASSOCIATED(C%PARENT_MAG)) CALL COPY(C%MAG,C%MAGP)
       C=>C%NEXT
    ENDDO

    CALL RING_L(R,DONEIT)

  END SUBROUTINE EL_TO_ELP_L

  SUBROUTINE ELP_TO_EL_L(R) ! COPY ALL PRIMITIVES ELEMENTP INTO ELEMENT
    IMPLICIT  NONE
    TYPE(LAYOUT), INTENT(INOUT):: R
    TYPE (FIBRE), POINTER :: C
    LOGICAL(LP) DONEIT
    NULLIFY(C)

    CALL LINE_L(R,DONEIT)
    C=>R%START
    DO   WHILE(ASSOCIATED(C))

       IF(.NOT.ASSOCIATED(C%PARENT_MAG)) CALL COPY(C%MAGP,C%MAG)

       C=>C%NEXT
    ENDDO

    CALL RING_L(R,DONEIT)
  END SUBROUTINE ELP_TO_EL_L




END  MODULE        S_FAMILY
