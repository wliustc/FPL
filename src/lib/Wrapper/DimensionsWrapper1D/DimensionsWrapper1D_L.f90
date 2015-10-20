module DimensionsWrapper1D_L

USE DimensionsWrapper1D
USE IR_Precision, only: I4P, str

implicit none
private

    type, extends(DimensionsWrapper1D_t) :: DimensionsWrapper1D_L_t
        logical, allocatable :: Value(:)
    contains
    private
        procedure         ::                 DimensionsWrapper1D_L_Set
        procedure         ::                 DimensionsWrapper1D_L_Get
        generic,   public :: Set          => DimensionsWrapper1D_L_Set
        generic,   public :: Get          => DimensionsWrapper1D_L_Get
        procedure, public :: isOfDataType => DimensionsWrapper1D_L_isOfDataType
        procedure, public :: Free         => DimensionsWrapper1D_L_Free
        procedure, public :: Print        => DimensionsWrapper1D_L_Print
        final             ::                 DimensionsWrapper1D_L_Final
    end type           

public :: DimensionsWrapper1D_L_t

contains


    subroutine DimensionsWrapper1D_L_Final(this) 
    !-----------------------------------------------------------------
    !< Final procedure of DimensionsWrapper1D
    !-----------------------------------------------------------------
        type(DimensionsWrapper1D_L_t), intent(INOUT) :: this
    !-----------------------------------------------------------------
        call this%Free()
    end subroutine


    subroutine DimensionsWrapper1D_L_Set(this, Value) 
    !-----------------------------------------------------------------
    !< Set logical Wrapper Value
    !-----------------------------------------------------------------
        class(DimensionsWrapper1D_L_t), intent(INOUT) :: this
        class(*),                       intent(IN)    :: Value(:)
    !-----------------------------------------------------------------
        select type (Value)
            type is (logical)
                allocate(this%Value(size(Value,dim=1)), source=Value)
        end select
    end subroutine


    subroutine DimensionsWrapper1D_L_Get(this, Value) 
    !-----------------------------------------------------------------
    !< Get logical Wrapper Value
    !-----------------------------------------------------------------
        class(DimensionsWrapper1D_L_t), intent(IN)  :: this
        logical, allocatable,           intent(OUT) :: Value(:)
    !-----------------------------------------------------------------
        allocate(Value(size(this%Value,dim=1)), source=this%Value)
    end subroutine


    subroutine DimensionsWrapper1D_L_Free(this) 
    !-----------------------------------------------------------------
    !< Free a DimensionsWrapper1D
    !-----------------------------------------------------------------
        class(DimensionsWrapper1D_L_t), intent(INOUT) :: this
    !-----------------------------------------------------------------
        if(allocated(this%Value)) deallocate(this%Value)
    end subroutine


    function DimensionsWrapper1D_L_isOfDataType(this, Mold) result(isOfDataType)
    !-----------------------------------------------------------------
    !< Check if Mold and Value are of the same datatype 
    !-----------------------------------------------------------------
        class(DimensionsWrapper1D_L_t), intent(IN) :: this            !< Dimensions wrapper 1D
        class(*),                       intent(IN) :: Mold            !< Mold for data type comparison
        logical                                    :: isOfDataType    !< Boolean flag to check if Value is of the same data type as Mold
    !-----------------------------------------------------------------
        isOfDataType = .false.
        select type (Mold)
            type is (logical)
                isOfDataType = .true.
        end select
    end function DimensionsWrapper1D_L_isOfDataType


    subroutine DimensionsWrapper1D_L_Print(this, unit, prefix, iostat, iomsg)
    !-----------------------------------------------------------------
    !< Print Wrapper
    !-----------------------------------------------------------------
        class(DimensionsWrapper1D_L_t),   intent(IN)  :: this         !< DimensionsWrapper
        integer(I4P),                     intent(IN)  :: unit         !< Logic unit.
        character(*), optional,           intent(IN)  :: prefix       !< Prefixing string.
        integer(I4P), optional,           intent(OUT) :: iostat       !< IO error.
        character(*), optional,           intent(OUT) :: iomsg        !< IO error message.
        character(len=:), allocatable                 :: prefd        !< Prefixing string.
        integer(I4P)                                  :: iostatd      !< IO error.
        character(500)                                :: iomsgd       !< Temporary variable for IO error message.
    !-----------------------------------------------------------------
        prefd = '' ; if (present(prefix)) prefd = prefix
        write(unit=unit,fmt='(A)',iostat=iostatd,iomsg=iomsgd) prefd//' Data Type = L'//&
                            ', Dimensions = '//trim(str(no_sign=.true., n=this%GetDimensions()))//&
                            ', Value = '//str(n=this%Value)
        if (present(iostat)) iostat = iostatd
        if (present(iomsg))  iomsg  = iomsgd
    end subroutine DimensionsWrapper1D_L_Print

end module DimensionsWrapper1D_L
