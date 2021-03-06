# Version parsing tests
@test v"1" == VersionNumber(1)
@test v"2.1" == VersionNumber(2, 1)
@test v"3.2.1" == VersionNumber(3, 2, 1)

@test v"2-1" == VersionNumber(2, 0, 0, (1,), ())
@test v"3.2-1" == VersionNumber(3, 2, 0, (1,), ())
@test v"4.3.2-1" == VersionNumber(4, 3, 2, (1,), ())

@test v"1-a" == VersionNumber(1, 0, 0, ("a",), ())
@test v"2.1-a" == VersionNumber(2, 1, 0, ("a",), ())
@test v"3.2.1-a" == VersionNumber(3, 2, 1, ("a",), ())

@test v"2-a1" == VersionNumber(2, 0, 0, ("a1",), ())
@test v"3.2-a1" == VersionNumber(3, 2, 0, ("a1",), ())
@test v"4.3.2-a1" == VersionNumber(4, 3, 2, ("a1",), ())

@test v"2-1a" == VersionNumber(2, 0, 0, ("1a",), ())
@test v"3.2-1a" == VersionNumber(3, 2, 0, ("1a",), ())
@test v"4.3.2-1a" == VersionNumber(4, 3, 2, ("1a",), ())

@test v"2-a.1" == VersionNumber(2, 0, 0, ("a", 1), ())
@test v"3.2-a.1" == VersionNumber(3, 2, 0, ("a", 1), ())
@test v"4.3.2-a.1" == VersionNumber(4, 3, 2, ("a", 1), ())

@test v"2-1.a" == VersionNumber(2, 0, 0, (1, "a"), ())
@test v"3.2-1.a" == VersionNumber(3, 2, 0, (1, "a"), ())
@test v"4.3.2-1.a" == VersionNumber(4, 3, 2, (1, "a"), ())

@test v"2+1" == VersionNumber(2, 0, 0, (), (1,))
@test v"3.2+1" == VersionNumber(3, 2, 0, (), (1,))
@test v"4.3.2+1" == VersionNumber(4, 3, 2, (), (1,))

@test v"1+a" == VersionNumber(1, 0, 0, (), ("a",))
@test v"2.1+a" == VersionNumber(2, 1, 0, (), ("a",))
@test v"3.2.1+a" == VersionNumber(3, 2, 1, (), ("a",))

@test v"2+a1" == VersionNumber(2, 0, 0, (), ("a1",))
@test v"3.2+a1" == VersionNumber(3, 2, 0, (), ("a1",))
@test v"4.3.2+a1" == VersionNumber(4, 3, 2, (), ("a1",))

@test v"2+1a" == VersionNumber(2, 0, 0, (), ("1a",))
@test v"3.2+1a" == VersionNumber(3, 2, 0, (), ("1a",))
@test v"4.3.2+1a" == VersionNumber(4, 3, 2, (), ("1a",))

@test v"2+a.1" == VersionNumber(2, 0, 0, (), ("a", 1))
@test v"3.2+a.1" == VersionNumber(3, 2, 0, (), ("a", 1))
@test v"4.3.2+a.1" == VersionNumber(4, 3, 2, (), ("a", 1))

@test v"2+1.a" == VersionNumber(2, 0, 0, (), (1, "a"))
@test v"3.2+1.a" == VersionNumber(3, 2, 0, (), (1, "a"))
@test v"4.3.2+1.a" == VersionNumber(4, 3, 2, (), (1, "a"))
