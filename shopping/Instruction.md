ЛОКАЛЬНО
Изменить содержимое Filler.sol в соответствии с тем, как в начале видео
tondev sol compile ShoppingList.sol
tonos-cli decode stateinit ShoppingList.tvc --tvc
сохранить ShoppingList.decode.json


tondev sol compile Filler.sol
tonos-cli genaddr Filler.tvc Filler.abi.json --genkey Filler.keys.json > Filler.log
Заполнить файл FillerParams.json
В моем случае:
{
    "dest": "0:a9f1ad79dd52e874de8a93edb43dd496fcb7f3491eff9815cc8c1876da9ce9b4",
    "amount": 10000000000
}
Закинуть денег
tonos-cli --url http://127.0.0.1 call --abi ../debots/local_giver.abi.json 0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94 sendGrams FillerParams.json
Задеплоить
tonos-cli --url http://127.0.0.1 deploy Filler.tvc "{}" --sign Filler.keys.json --abi Filler.abi.json
bash
cat Filler.abi.json | xxd -p -c 20000
exit
Записать Filler.dabi.json - в моем случае:
{
    "dabi": "7b0d0a0........d0a7d0d0a"
}
Установить dabi
tonos-cli --url http://127.0.0.1 call 0:d2c95e648ba1222cdf0b21298ecee3fbd9fc0dabab273e92683d911a69ba988f setABI Filler.dabi.json --sign Filler.keys.json --abi Filler.abi.json
!!!!!!!!!
предварительно сформировать ShoppingList.decode.json
tonos-cli --url http://127.0.0.1 call --abi Filler.abi.json --sign Filler.keys.json 0:d2c95e648ba1222cdf0b21298ecee3fbd9fc0dabab273e92683d911a69ba988f setCode ShoppingList.decode.json
Вызываем дебота
tonos-cli --url http://127.0.0.1 debot fetch 0:d2c95e648ba1222cdf0b21298ecee3fbd9fc0dabab273e92683d911a69ba988f
Ошибка, которую можно получить, если не перейти на иную работу со stateInit как в лекции:
Debot error: Contract execution was terminated with error: Unknown error, exit code: 55 (Bad StateInit cell for tvm_insert_pubkey. Data was not found.)

ИЗ ДЕВНЕТ СЕТИ
+ tondev sol compile ShoppingList.sol
+ tonos-cli decode stateinit ShoppingList.tvc --tvc
+ сохранить ShoppingList.decode.json



+ tondev sol compile Filler.sol
+? tonos-cli genaddr Filler.tvc Filler.abi.json --genkey Filler.keys.json > Filler.log
Закинуть денег
вместо этого EXTRATON
Задеплоить
tonos-cli --url https://net.ton.dev deploy Filler.tvc "{}" --sign Filler.keys.json --abi Filler.abi.json
+ bash
+ cat Filler.abi.json | xxd -p -c 20000
exit
+ Записать dabi.json - в моем случае:
{
    "dabi": "7b0d0a0........d0a7d0d0a"
}
Установить dabi
tonos-cli --url https://net.ton.dev call 0:c092e6f1117373c967d2049366392251936b9eaf856658d81b3ff7cdbb20f2f0 setABI Filler.dabi.json --sign Filler.keys.json --abi Filler.abi.json
!!!!!!!!!
предварительно сформировать ShoppingList.decode.json
tonos-cli --url https://net.ton.dev call --abi Filler.abi.json --sign Filler.keys.json 0:c092e6f1117373c967d2049366392251936b9eaf856658d81b3ff7cdbb20f2f0 setCode ShoppingList.decode.json
Вызываем дебота
=- tonos-cli --url https://net.ton.dev debot --debug fetch 0:c092e6f1117373c967d2049366392251936b9eaf856658d81b3ff7cdbb20f2f0
https://web.ton.surf/debot?address=0%3Ac092e6f1117373c967d2049366392251936b9eaf856658d81b3ff7cdbb20f2f0&net=devnet&restart=true

- мой публичный ключ: 6594a9978ba60315d9c71b0ad07710d320ed9850eddee3d12211417211bb454b