module DimensionsWrapper1D

USE DimensionsWrapper
USE IR_Precision, only: I4P, str

implicit none
private

    type, extends(DimensionsWrapper_t), abstract :: DimensionsWrapper1D_t
    private
    contains
        procedure :: Print => DimensionsWrapper1D_Print
        procedure(DimensionsWrapper1D_isOfDataType), deferred :: isOfDataType
        procedure(DimensionsWrapper1D_Free),         deferred :: Free
    end type

    abstract interface
        subroutine DimensionsWrapper1D_Free(this)
            import DimensionsWrapper1D_t
            class(DimensionsWrapper1D_t), intent(INOUT) :: this
        end subroutine
        function DimensionsWrapper1D_isOfDataType(this, Mold) result(isOfDataType)
            import DimensionsWrapper1D_t
            class(DimensionsWrapper1D_t), intent(IN) :: this
            class(*),                   intent(IN) :: Mold
            logical                                :: isOfDataType
        end function
    end interface

public :: DimensionsWrapper1D_t

contains

    subroutine DimensionsWrapper1D_Print(this, unit, prefix, iostat, iomsg)
    !-----------------------------------------------------------------
    !< Generic Print Wrapper
    !-----------------------------------------------------------------
        class(DimensionsWrapper1D_t),     intent(IN)  :: this         !< DimensionsWrapper
        integer(I4P),                     intent(IN)  :: unit         !< Logic unit.
        character(*), optional,           intent(IN)  :: prefix       !< Prefixing string.
        integer(I4P), optional,           intent(OUT) :: iostat       !< IO error.
        character(*), optional,           intent(OUT) :: iomsg        !< IO error message.
        character(len=:), allocatable                 :: prefd        !< Prefixing string.
        integer(I4P)                                  :: iostatd      !< IO error.
        character(500)                                :: iomsgd       !< Temporary variable for IO error message.
    !-----------------------------------------------------------------
        prefd = '' ; if (present(prefix)) prefd = prefix
        write(unit=unit,fmt='(A)',iostat=iostatd,iomsg=iomsgd) prefd//' Data Type = -, '//&
                            ', Dimensions = '//trim(str(no_sign=.true., n=this%GetDimensions()))
        if (present(iostat)) iostat = iostatd
        if (present(iomsg))  iomsg  = iomsgd
    end subroutine DimensionsWrapper1D_Print

end module DimensionsWrapper1D
