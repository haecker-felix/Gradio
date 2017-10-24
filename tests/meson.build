tests = [
  'library',
]

foreach test_name : tests
  testcase = executable(
    test_name,
    test_name + '.vala',
  )
  test(test_name, testcase)
endforeach

