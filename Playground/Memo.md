# Memo

https://koherent.org/pi/pi1000000.txt

https://github.com/apple/swift-async-algorithms.git

---

`@rethrows` が付与されたプロトコルを `@rethrows` プロトコルと呼ぶことにする。また、 `P` が `@rethrows` プロトコルのとき 、 `func foo<T: P>(_ x: T) rethrows` が `throws` になる場合、 `T` が rethrowing であると呼ぶことにする。

このとき、 `T` が non-rethrowing である条件は、下記の二つが同時に満たされる場合に限る。

- `P` のメソッドの内、 `throws` が付与されたものをすべて non-`throws` なメソッドとして実装する
- `P` の `associatedtype` の内、 `@rethrows` プロトコルを制約として持つものをすべて non-rethrowing な型で実装する

https://discord.com/channels/291054398077927425/306995750418513920/1000973315738959973

---

shiz — 01/23/2023 7:38 PM
そういえば、昨年のWWDCのデジタルラウンジで「SwiftUIとやりとりするのはAsyncSequenceよりも＠Published使う方が今のところまだ良い」といったことをこのPitchの作者が言ってたのを思い出しました。その時点ではまだObservationの話は出てなかったんですかねw(もしくは言えなかったのか)

https://discord.com/channels/291054398077927425/380329942505750529/1067030503334608918
