!------------------------------------------------------------------------------!
!
!   PROGRAM : LES_Filtering_output.f90
!
!   PURPOSE : Write each variables in the RESULT folder.
!
!                                                             2016.12.07 K.Noh
!
!------------------------------------------------------------------------------!
          SUBROUTINE OUTPUT
              USE LES_FILTERING_module,                                         &
                  ONLY : J_det

              USE LES_FILTERING_module,                                         &
                  ONLY : Nx, Ny, Nz, file_name, dir_name, path_name

              USE LES_FILTERING_module,                                         &
                  ONLY : X, Y, Z, U, V, W, U_Fil, V_Fil, W_Fil, dy, Resi_T,     &
                         S_T, S_T_Fil, NU_R

              IMPLICIT NONE
              INTEGER :: i,j,k,it,J_loc,v_i,v_j
              REAL(KIND=8) :: time_sta, time_end, U_ave, V_ave, W_ave
              REAL(KIND=8) :: YP(1:3), RESI_ave(1:3,1:3), NU_R_ave(1:3,1:3)
              WRITE(*,*) '----------------------------------------------------'
              WRITE(*,*) '              WRITING PROCESS STARTED               '
              CALL CPU_TIME(time_sta)

              !----------------------------------------------------------------!
              !                Outputs for U_Fil(Filtered velocity)
              !----------------------------------------------------------------!
              dir_name = 'RESULT/U'

              file_name = '/U_filtered.plt'
              path_name = TRIM(dir_name)//TRIM(file_name)
              OPEN(100,FILE=path_name,FORM='FORMATTED',POSITION='APPEND')
              WRITE(100,*) 'VARIABLES = X,Y,Z,U_fil,V_Fil,W_Fil'
              WRITE(100,"(3(A,I3,2X))")' ZONE  I = ',Nx,' J = ',Ny, ' K = ', Nz
              DO k = 1,Nz
                DO j = 1,Ny
                  DO i = 1,Nx
                    WRITE(100,"(6F15.9)") X(i),Y(j),Z(k),                       &
                                          U_fil(i,j,k),V_Fil(i,j,k),W_Fil(i,j,k)
                  END DO
                END DO
              END DO
              CLOSE(100)

              !----------------------------------------------------------------!
              !            Outputs for Averaged U on x,z directions            !
              !----------------------------------------------------------------!
              file_name = '/U_averaged_profile.plt'
              path_name = TRIM(dir_name)//TRIM(file_name)
              OPEN(100,FILE=path_name,FORM='FORMATTED',POSITION='APPEND')
              WRITE(100,*) 'VARIABLES = Y,U_ave,V_ave,W_ave'

              DO j = 1,Ny
                U_ave = 0.0
                V_ave = 0.0
                W_ave = 0.0

                DO k = 1,Nz
                  DO i = 1,Nx
                    U_ave = U_ave + U_fil(i,j,k)
                    V_ave = V_ave + V_fil(i,j,k)
                    W_ave = W_ave + W_fil(i,j,k)
                  END DO
                END DO
                U_ave = U_ave/(Nx*Nz)
                V_ave = V_ave/(Nx*Nz)
                W_ave = W_ave/(Nx*Nz)

                WRITE(100,"(4F15.9)")Y(j),U_ave,V_ave,W_ave
              END DO
              CLOSE(100)

              !----------------------------------------------------------------!
              !            Outputs for instaneous U at Y+ = 5,30,200           !
              !----------------------------------------------------------------!
              YP = [5,30,200]

              DO it = 1,3

                WRITE(file_name,"(I3.3,A)")INT(YP(it)),'.U_slice.plt'
                path_name = TRIM(dir_name)//'/'//TRIM(file_name)
                OPEN(100,FILE=path_name,FORM='FORMATTED',POSITION='APPEND')
                WRITE(100,*)'VARIABLES = X,Z,U_fil,V_fil,W_fil,U,V,W'
                WRITE(100,"(2(A,I3,2X))")' ZONE  I = ',Nx,' K = ', Nz

                J_loc = J_det(YP(it))
                DO k = 1,Nz
                  DO i = 1,Nx
                    WRITE(100,"(8F15.9)") X(i),Z(k),                            &
                            U_fil(i,J_loc,k),V_Fil(i,J_loc,k),W_Fil(i,J_loc,k), &
                            U(i,J_loc,k),V(i,J_loc,k),W(i,J_loc,k)
                  END DO
                END DO

                CLOSE(100)
              END DO

              !----------------------------------------------------------------!
              !              Outputs for Residual at Y+ = 5,30,200             !
              !----------------------------------------------------------------!
              dir_name = 'RESULT/RESI'

              YP = [5,30,200]

              DO it = 1,3

                WRITE(file_name,"(I3.3,A)")INT(YP(it)),'.Resi_slice.plt'
                path_name = TRIM(dir_name)//'/'//TRIM(file_name)
                OPEN(100,FILE=path_name,FORM='FORMATTED',POSITION='APPEND')
                WRITE(100,*)'VARIABLES = X,Z,UU,UV,UW,VU,VV,VW,WU,WV,WW'
                WRITE(100,"(2(A,I3,2X))")' ZONE  I = ',Nx,' K = ', Nz

                J_loc = J_det(YP(it))
                DO k = 1,Nz
                  DO i = 1,Nx
                    WRITE(100,"(11F15.9)") X(i),Z(k),Resi_T(i,J_loc,k,1:3,1:3)
                  END DO
                END DO

                CLOSE(100)
              END DO

              !----------------------------------------------------------------!
              !            Outputs for Averaged U on x,z directions            !
              !----------------------------------------------------------------!
              file_name = '/Resi_averaged_profile.plt'
              path_name = TRIM(dir_name)//TRIM(file_name)
              OPEN(100,FILE=path_name,FORM='FORMATTED',POSITION='APPEND')
              WRITE(100,*) 'VARIABLES = Y,U,UV,UW,VU,VV,VW,WU,WV,WW'

              DO j = 1,Ny
                RESI_ave(1:3,1:3) = 0.0

                DO k = 1,Nz
                  DO i = 1,Nx

                    DO v_i = 1,3
                      DO v_j = 1,3
                        RESI_ave(v_i,v_j) = RESI_ave(v_i,v_j)                   &
                                          + Resi_T(i,j,k,v_i,v_j)
                      END DO
                    END DO

                  END DO
                END DO
                RESI_ave(1:3,1:3) = RESI_ave(1:3,1:3)/(Nx*Nz)

                WRITE(100,"(10F15.9)")Y(j),RESI_ave(1:3,1:3)

              END DO
              CLOSE(100)

              !----------------------------------------------------------------!
              !            Outputs for eddy-viscosity at Y+ = 5,30,200         !
              !----------------------------------------------------------------!
              dir_name = 'RESULT/EDDY_VISCOSITY'

              YP = [5,30,200]

              DO it = 1,3

                WRITE(file_name,"(I3.3,A)")INT(YP(it)),'.NU_R_slice.plt'
                path_name = TRIM(dir_name)//'/'//TRIM(file_name)
                OPEN(100,FILE=path_name,FORM='FORMATTED',POSITION='APPEND')
                WRITE(100,*)'VARIABLES = X,Z,NU_11,NU_12,NU_13,NU_21,NU_22,NU_23&
                                            ,NU_31,NU_32,NU_33,NU'
                WRITE(100,"(2(A,I3,2X))")' ZONE  I = ',Nx,' K = ', Nz

                J_loc = J_det(YP(it))
                DO k = 1,Nz
                  DO i = 1,Nx
                    WRITE(100,"(12F15.9)") X(i),Z(k),NU_R(i,J_loc,k,1:3,1:3),   &
                                           SUM(NU_R(i,J_loc,k,1:3,1:3))
                  END DO
                END DO

                CLOSE(100)
              END DO

              !----------------------------------------------------------------!
              !      Outputs for Averaged eddy-viscosity on x,z directions     !
              !----------------------------------------------------------------!
              file_name = '/NU_R_averaged_profile.plt'
              path_name = TRIM(dir_name)//TRIM(file_name)
              OPEN(100,FILE=path_name,FORM='FORMATTED',POSITION='APPEND')
              WRITE(100,*)'VARIABLES = Y,NU_11,NU_12,NU_13,NU_21,NU_22,NU_23&
                                        ,NU_31,NU_32,NU_33'

              DO j = 1,Ny
                NU_R_ave(1:3,1:3) = 0.0

                DO k = 1,Nz
                  DO i = 1,Nx

                    DO v_i = 1,3
                      DO v_j = 1,3
                        NU_R_ave(v_i,v_j) = NU_R_ave(v_i,v_j)                   &
                                          + NU_R(i,j,k,v_i,v_j)
                      END DO
                    END DO

                  END DO
                END DO
                NU_R_ave(1:3,1:3) = NU_R_ave(1:3,1:3)/(Nx*Nz)

                WRITE(100,"(10F15.9)")Y(j),NU_R_ave(1:3,1:3)

              END DO
              CLOSE(100)
              CALL CPU_TIME(time_end)

              WRITE(*,*) '           WRITING PROCESS IS COMPLETED            '
              WRITE(*,*) '  Total Writing time : ',time_end - time_sta,' s'
              WRITE(*,*) '----------------------------------------------------'
              WRITE(*,*) ''

              DEALLOCATE(X,Y,Z,U,V,W,U_Fil,V_Fil,W_Fil,dy,S_T,S_T_Fil)

          END SUBROUTINE OUTPUT
