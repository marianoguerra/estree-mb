{
  using a = resource();
  using b = r1(), c = r2();
}
async function f() {
  await using x = resource();
  for (using y of list) {}
  for (await using z of list) {}
  for await (await using w of list) {}
}
