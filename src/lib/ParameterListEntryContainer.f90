    !-----------------------------------------------------------------
    ! ParameterListEntryContainer is a datatype containing a DataBase
    ! array of ParameterListEntries made to store diferent Entries
    ! depending on the hash of his Key.
    !
    ! This work takes as a starting point the previou work of
    ! Stefano Zaghi (@szaghi, https://github.com/szaghi).
    !
    ! You can find the original source at:
    ! https://github.com/szaghi/OFF/blob/95691ca15e6d68128ba016e40df74e42123f1c54/src/Data_Type_Hash_Table.f90
    !-----------------------------------------------------------------

module ParameterListEntryContainer

USE IR_Precision
USE ParameterListEntry
USE WrapperFactoryList
USE WrapperFactory
USE DimensionsWrapper

implicit none
private
save

    integer(I4P), parameter:: DefaultDataBaseSize = 999_I4P

    type, public:: ParameterListEntryContainer_t
    private
        type(WrapperFactoryList_t)              :: WrapperFactoryList
        type(ParameterListEntry_t), allocatable :: DataBase(:)
        integer(I4P)                            :: Size = 0_I4P
    contains
    private
        procedure         ::                   ParameterListEntryContainer_Set0D
        procedure         ::                   ParameterListEntryContainer_Set1D
        procedure         ::                   ParameterListEntryContainer_Set2D
        procedure         ::                   ParameterListEntryContainer_Set3D
        procedure         ::                   ParameterListEntryContainer_Set4D
        procedure         ::                   ParameterListEntryContainer_Set5D
        procedure         ::                   ParameterListEntryContainer_Set6D
        procedure         ::                   ParameterListEntryContainer_Set7D
        procedure         ::                   ParameterListEntryContainer_Get0D
        procedure         ::                   ParameterListEntryContainer_Get1D
        procedure         ::                   ParameterListEntryContainer_Clone1D
        procedure         :: Hash           => ParameterListEntryContainer_Hash
        procedure, public :: Init           => ParameterListEntryContainer_Init
        procedure, public :: Free           => ParameterListEntryContainer_Free
        generic,   public :: Set            => ParameterListEntryContainer_Set0D, &
                                               ParameterListEntryContainer_Set1D, &
                                               ParameterListEntryContainer_Set2D, &
                                               ParameterListEntryContainer_Set3D, &
                                               ParameterListEntryContainer_Set4D, &
                                               ParameterListEntryContainer_Set5D, &
                                               ParameterListEntryContainer_Set6D, &
                                               ParameterListEntryContainer_Set7D
        generic,   public :: Get            => ParameterListEntryContainer_Get0D, &
                                               ParameterListEntryContainer_Get1D
        generic,   public :: Clone          => ParameterListEntryContainer_Clone1D
!        procedure, public :: isPresent      => ParameterListEntryContainer_isPresent
!        procedure, public :: isOfDataType   => ParameterListEntryContainer_isOfDataType
!        procedure, public :: isSubList      => ParameterListEntryContainer_isSubList
        procedure, public :: Del            => ParameterListEntryContainer_RemoveEntry
        procedure, public :: Length         => ParameterListEntryContainer_GetLength
        final             ::                   ParameterListEntryContainer_Finalize
    end type ParameterListEntryContainer_t


contains


    function ParameterListEntryContainer_Hash(this,Key) result(Hash)
    !-----------------------------------------------------------------
    !< String hash function
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(IN) :: this        !< Parameter List Entry Containter type
        character(len=*),                     intent(IN) :: Key         !< String Key
        integer(I4P)                                     :: Hash        !< Hash code
        character, dimension(len(Key))                   :: CharArray   !< Character array containing the Key
        integer(I4P)                                     :: CharIterator!< Char iterator index
    !-----------------------------------------------------------------
        forall (CharIterator=1:LEN(Key))
            CharArray(CharIterator) = Key(CharIterator:CharIterator)
        end forall
        Hash = MOD(SUM(ICHAR(CharArray)), this%Size)
    end function ParameterListEntryContainer_Hash


    subroutine ParameterListEntryContainer_Init(this,Size)
    !-----------------------------------------------------------------
    !< Allocate the database with a given Szie of DefaultDataBaseSize
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(INOUT) :: this   !< Parameter List Entry Containter type
        integer(I4P), optional,               intent(IN)    :: Size   !< DataBase Size
    !-----------------------------------------------------------------
        call this%Free()
        if (present(Size)) then
            this%Size = Size
        else
            this%Size = DefaultDataBaseSize
        endif
        allocate(this%DataBase(0:this%Size-1))
        call this%WrapperFactoryList%Init()
    end subroutine ParameterListEntryContainer_Init


    subroutine ParameterListEntryContainer_Free(this)
    !-----------------------------------------------------------------
    !< Free ParameterListEntries and the DataBase
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(INOUT) :: this       !< Parameter List Entry Containter type
        integer(I4P)                                        :: DBIterator !< Database Iterator index 
    !-----------------------------------------------------------------
        call this%WrapperFactoryList%Free()
        if (allocated(this%DataBase)) THEN
            do DBIterator=lbound(this%DataBase,dim=1),ubound(this%DataBase,dim=1)
                call this%DataBase(DBIterator)%Free()
            enddo
            deallocate(this%DataBase)
        endif
        this%Size = 0_I4P
    end subroutine ParameterListEntryContainer_Free


    subroutine ParameterListEntryContainer_Finalize(this)
    !-----------------------------------------------------------------
    !< Destructor procedure
    !-----------------------------------------------------------------
        type(ParameterListEntryContainer_t), intent(INOUT) :: this    !< Parameter List Entry Containter type
    !-----------------------------------------------------------------
        call this%Free()
    end subroutine ParameterListEntryContainer_Finalize


    subroutine ParameterListEntryContainer_Set0D(this,Key,Value)
    !-----------------------------------------------------------------
    !< Set a Key/Value pair into the DataBase
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(INOUT) :: this    !< Parameter List Entry Containter type
        character(len=*),                     intent(IN)    :: Key     !< String Key
        class(*),                             intent(IN)    :: Value   !< Unlimited polymorphic Value
        class(WrapperFactory_t),    pointer                 :: WrapperFactory
        class(DimensionsWrapper_t), allocatable             :: Wrapper
    !-----------------------------------------------------------------
        WrapperFactory => this%WrapperFactoryList%GetFactory(Value=Value)
        if(associated(WrapperFactory)) call WrapperFactory%Wrap(Value=Value, Wrapper=Wrapper)
        if(allocated(Wrapper)) then
            call this%DataBase(this%Hash(Key=Key))%AddNode(Key=Key,Value=Wrapper)
            call Wrapper%Free()
            deallocate(Wrapper)
        endif
    end subroutine ParameterListEntryContainer_Set0D


    subroutine ParameterListEntryContainer_Set1D(this,Key,Value)
    !-----------------------------------------------------------------
    !< Set a Key/Value pair into the DataBase
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(INOUT) :: this    !< Parameter List Entry Containter type
        character(len=*),                     intent(IN)    :: Key     !< String Key
        class(*),                             intent(IN)    :: Value(:)
        class(WrapperFactory_t),    pointer                 :: WrapperFactory
        class(DimensionsWrapper_t), allocatable             :: Wrapper
    !-----------------------------------------------------------------
        WrapperFactory => this%WrapperFactoryList%GetFactory(Value=Value)
        if(associated(WrapperFactory)) call WrapperFactory%Wrap(Value=Value, Wrapper=Wrapper)
        if(allocated(Wrapper)) then
            call Wrapper%Print(unit=6)
            call this%DataBase(this%Hash(Key=Key))%AddNode(Key=Key,Value=Wrapper)
            call Wrapper%Free()
            deallocate(Wrapper)
        endif
    end subroutine ParameterListEntryContainer_Set1D


    subroutine ParameterListEntryContainer_Set2D(this,Key,Value)
    !-----------------------------------------------------------------
    !< Set a Key/Value pair into the DataBase
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(INOUT) :: this    !< Parameter List Entry Containter type
        character(len=*),                     intent(IN)    :: Key     !< String Key
        class(*),                             intent(IN)    :: Value(:,:)
        class(WrapperFactory_t),    pointer                 :: WrapperFactory
        class(DimensionsWrapper_t), allocatable             :: Wrapper
    !-----------------------------------------------------------------
        WrapperFactory => this%WrapperFactoryList%GetFactory(Value=Value)
        if(associated(WrapperFactory)) call WrapperFactory%Wrap(Value=Value, Wrapper=Wrapper)
        if(allocated(Wrapper)) then
            call this%DataBase(this%Hash(Key=Key))%AddNode(Key=Key,Value=Wrapper)
            call Wrapper%Free()
            deallocate(Wrapper)
        endif
    end subroutine ParameterListEntryContainer_Set2D


    subroutine ParameterListEntryContainer_Set3D(this,Key,Value)
    !-----------------------------------------------------------------
    !< Set a Key/Value pair into the DataBase
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(INOUT) :: this    !< Parameter List Entry Containter type
        character(len=*),                     intent(IN)    :: Key     !< String Key
        class(*),                             intent(IN)    :: Value(:,:,:)
        class(WrapperFactory_t),    pointer                 :: WrapperFactory
        class(DimensionsWrapper_t), allocatable             :: Wrapper
    !-----------------------------------------------------------------
        WrapperFactory => this%WrapperFactoryList%GetFactory(Value=Value)
        if(associated(WrapperFactory)) call WrapperFactory%Wrap(Value=Value, Wrapper=Wrapper)
        if(allocated(Wrapper)) then
            call this%DataBase(this%Hash(Key=Key))%AddNode(Key=Key,Value=Wrapper)
            call Wrapper%Free()
            deallocate(Wrapper)
        endif
    end subroutine ParameterListEntryContainer_Set3D


    subroutine ParameterListEntryContainer_Set4D(this,Key,Value)
    !-----------------------------------------------------------------
    !< Set a Key/Value pair into the DataBase
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(INOUT) :: this    !< Parameter List Entry Containter type
        character(len=*),                     intent(IN)    :: Key     !< String Key
        class(*),                             intent(IN)    :: Value(:,:,:,:)
        class(WrapperFactory_t),    pointer                 :: WrapperFactory
        class(DimensionsWrapper_t), allocatable             :: Wrapper
    !-----------------------------------------------------------------
        WrapperFactory => this%WrapperFactoryList%GetFactory(Value=Value)
        if(associated(WrapperFactory)) call WrapperFactory%Wrap(Value=Value, Wrapper=Wrapper)
        if(allocated(Wrapper)) then
            call this%DataBase(this%Hash(Key=Key))%AddNode(Key=Key,Value=Wrapper)
            call Wrapper%Free()
            deallocate(Wrapper)
        endif
    end subroutine ParameterListEntryContainer_Set4D


    subroutine ParameterListEntryContainer_Set5D(this,Key,Value)
    !-----------------------------------------------------------------
    !< Set a Key/Value pair into the DataBase
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(INOUT) :: this    !< Parameter List Entry Containter type
        character(len=*),                     intent(IN)    :: Key     !< String Key
        class(*),                             intent(IN)    :: Value(:,:,:,:,:)
        class(WrapperFactory_t),    pointer                 :: WrapperFactory
        class(DimensionsWrapper_t), allocatable             :: Wrapper
    !-----------------------------------------------------------------
        WrapperFactory => this%WrapperFactoryList%GetFactory(Value=Value)
        if(associated(WrapperFactory)) call WrapperFactory%Wrap(Value=Value, Wrapper=Wrapper)
        if(allocated(Wrapper)) then
            call this%DataBase(this%Hash(Key=Key))%AddNode(Key=Key,Value=Wrapper)
            call Wrapper%Free()
            deallocate(Wrapper)
        endif
    end subroutine ParameterListEntryContainer_Set5D


    subroutine ParameterListEntryContainer_Set6D(this,Key,Value)
    !-----------------------------------------------------------------
    !< Set a Key/Value pair into the DataBase
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(INOUT) :: this    !< Parameter List Entry Containter type
        character(len=*),                     intent(IN)    :: Key     !< String Key
        class(*),                             intent(IN)    :: Value(:,:,:,:,:,:)
        class(WrapperFactory_t),    pointer                 :: WrapperFactory
        class(DimensionsWrapper_t), allocatable             :: Wrapper
    !-----------------------------------------------------------------
        WrapperFactory => this%WrapperFactoryList%GetFactory(Value=Value)
        if(associated(WrapperFactory)) call WrapperFactory%Wrap(Value=Value, Wrapper=Wrapper)
        if(allocated(Wrapper)) then
            call this%DataBase(this%Hash(Key=Key))%AddNode(Key=Key,Value=Wrapper)
            call Wrapper%Free()
            deallocate(Wrapper)
        endif
    end subroutine ParameterListEntryContainer_Set6D


    subroutine ParameterListEntryContainer_Set7D(this,Key,Value)
    !-----------------------------------------------------------------
    !< Set a Key/Value pair into the DataBase
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(INOUT) :: this    !< Parameter List Entry Containter type
        character(len=*),                     intent(IN)    :: Key     !< String Key
        class(*),                             intent(IN)    :: Value(:,:,:,:,:,:,:)
        class(WrapperFactory_t),    pointer                 :: WrapperFactory
        class(DimensionsWrapper_t), allocatable             :: Wrapper
    !-----------------------------------------------------------------
        WrapperFactory => this%WrapperFactoryList%GetFactory(Value=Value)
        if(associated(WrapperFactory)) call WrapperFactory%Wrap(Value=Value, Wrapper=Wrapper)
        if(allocated(Wrapper)) then
            call this%DataBase(this%Hash(Key=Key))%AddNode(Key=Key,Value=Wrapper)
            call Wrapper%Free()
            deallocate(Wrapper)
        endif
    end subroutine ParameterListEntryContainer_Set7D


    subroutine ParameterListEntryContainer_Get0D(this,Key,Value)
    !-----------------------------------------------------------------
    !< Return an I1P scalar Value given the Key
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(IN)    :: this      !< Parameter List Entry Containter type
        character(len=*),                     intent(IN)    :: Key       !< String Key
        class(*),                             intent(INOUT) :: Value     
        class(*), pointer                                   :: Node
        class(WrapperFactory_t),    pointer                 :: WrapperFactory
        class(DimensionsWrapper_t), allocatable             :: Wrapper
    !-----------------------------------------------------------------
        Node => this%DataBase(this%Hash(Key=Key))%GetNode(Key=Key)
        if(associated(Node)) then
            select type(Node)
                type is (ParameterListEntry_t)
                    call Node%GetValue(Value=Wrapper)
                    if(allocated(Wrapper)) then
                        call Wrapper%Print(unit=6)
                        WrapperFactory => this%WrapperFactoryList%GetFactory(Value=Value)
                        if(associated(WrapperFactory)) call WrapperFactory%UnWrap(Wrapper=Wrapper, Value=Value)
                    endif
            end select
        end if
    end subroutine ParameterListEntryContainer_Get0D


    subroutine ParameterListEntryContainer_Get1D(this,Key,Value)
    !-----------------------------------------------------------------
    !< Return an I1P scalar Value given the Key
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(IN)    :: this      !< Parameter List Entry Containter type
        character(len=*),                     intent(IN)    :: Key       !< String Key
        class(*),                             intent(INOUT) :: Value(:)     
        class(*), pointer                                   :: Node
        class(WrapperFactory_t),    pointer                 :: WrapperFactory
        class(DimensionsWrapper_t), allocatable             :: Wrapper
    !-----------------------------------------------------------------
        Node => this%DataBase(this%Hash(Key=Key))%GetNode(Key=Key)
        if(associated(Node)) then
            select type(Node)
                type is (ParameterListEntry_t)
                    call Node%GetValue(Value=Wrapper)
                    if(allocated(Wrapper)) then
                        call Wrapper%Print(unit=6)
                        WrapperFactory => this%WrapperFactoryList%GetFactory(Value=Value)
                        if(associated(WrapperFactory)) call WrapperFactory%UnWrap(Wrapper=Wrapper, Value=Value)
                    endif
            end select
        end if
    end subroutine ParameterListEntryContainer_Get1D


    subroutine ParameterListEntryContainer_Clone1D(this,Key,Value)
    !-----------------------------------------------------------------
    !< Return an I1P scalar Value given the Key
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(IN)    :: this      !< Parameter List Entry Containter type
        character(len=*),                     intent(IN)    :: Key       !< String Key
        class(*), allocatable,                intent(INOUT) :: Value(:)     
        class(*), pointer                                   :: Node
        class(WrapperFactory_t),    pointer                 :: WrapperFactory
        class(DimensionsWrapper_t), allocatable             :: Wrapper
    !-----------------------------------------------------------------
        Node => this%DataBase(this%Hash(Key=Key))%GetNode(Key=Key)
        if(associated(Node)) then
            select type(Node)
                type is (ParameterListEntry_t)
                    call Node%GetValue(Value=Wrapper)
                    if(allocated(Wrapper)) then
                        call Wrapper%Print(unit=6)
                        WrapperFactory => this%WrapperFactoryList%GetFactory(Value=Value)
!                        if(associated(WrapperFactory)) call WrapperFactory%UnWrap(Wrapper=Wrapper, Value=Value)
                    endif
            end select
        end if
    end subroutine ParameterListEntryContainer_Clone1D


    function ParameterListEntryContainer_isPresent(this,Key) result(isPresent)
    !-----------------------------------------------------------------
    !< Check if a Key is present in the DataBase
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(IN) :: this      !< Parameter List Entry Containter type
        character(len=*),                     intent(IN) :: Key       !< String Key
        logical                                          :: isPresent !< Boolean flag to check if a Key is present
    !-----------------------------------------------------------------
        isPresent = this%DataBase(this%Hash(Key=Key))%isPresent(Key=Key)
    end function ParameterListEntryContainer_isPresent


    subroutine ParameterListEntryContainer_RemoveEntry(this,Key)
    !-----------------------------------------------------------------
    !< Remove a ParameterListEntry given a Key
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(INOUT) :: this   !< Parameter List Entry Containter type
        character(len=*),                     intent(IN)    :: Key    !< String Key
    !-----------------------------------------------------------------
        call this%DataBase(this%Hash(Key=Key))%RemoveNode(Key=Key)
        return
    end subroutine ParameterListEntryContainer_RemoveEntry


    function ParameterListEntryContainer_GetLength(this) result(Length)
    !-----------------------------------------------------------------
    !< Return the number of ParameterListEntries contained in the DataBase
    !-----------------------------------------------------------------
        class(ParameterListEntryContainer_t), intent(IN) :: this       !< Parameter List Entry Containter type
        integer(I4P)                                     :: Length     !< Number of parameters in database
        integer(I4P)                                     :: DBIterator !< Database Iterator index 
    !-----------------------------------------------------------------
        Length = 0
        if (allocated(this%DataBase)) THEN
            do DBIterator=lbound(this%DataBase,dim=1),ubound(this%DataBase,dim=1)
                Length = Length + this%DataBase(DBIterator)%GetLength()
            enddo
        endif
    end function ParameterListEntryContainer_GetLength


end module ParameterListEntryContainer