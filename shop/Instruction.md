ЛОКАЛЬНО
Изменить содержимое AddingPurchasesDeBot.sol в соответствии с тем, как в начале видео
tondev sol compile ShoppingList.sol
tonos-cli decode stateinit ShoppingList.tvc --tvc
сохранить ShoppingList.decode.json


tondev sol compile AddingPurchasesDeBot.sol
tonos-cli genaddr AddingPurchasesDeBot.tvc AddingPurchasesDeBot.abi.json --genkey AddingPurchasesDeBot.keys.json > AddingPurchasesDeBot.log
Заполнить файл FillerParams.json
В моем случае:
{
    "dest": "0:a9f1ad79dd52e874de8a93edb43dd496fcb7f3491eff9815cc8c1876da9ce9b4",
    "amount": 10000000000
}
Закинуть денег
tonos-cli --url http://127.0.0.1 call --abi ../debots/local_giver.abi.json 0:841288ed3b55d9cdafa806807f02a0ae0c169aa5edfe88a789a6482429756a94 sendGrams FillerParams.json
Задеплоить
tonos-cli --url http://127.0.0.1 deploy AddingPurchasesDeBot.tvc "{}" --sign AddingPurchasesDeBot.keys.json --abi AddingPurchasesDeBot.abi.json
bash
cat AddingPurchasesDeBot.abi.json | xxd -p -c 20000
exit
Записать AddingPurchasesDeBot.dabi.json - в моем случае:
{
    "dabi": "7b0d0a0........d0a7d0d0a"
}
Установить dabi
tonos-cli --url http://127.0.0.1 call 0:d2c95e648ba1222cdf0b21298ecee3fbd9fc0dabab273e92683d911a69ba988f setABI AddingPurchasesDeBot.dabi.json --sign AddingPurchasesDeBot.keys.json --abi AddingPurchasesDeBot.abi.json
!!!!!!!!!
предварительно сформировать ShoppingList.decode.json
tonos-cli --url http://127.0.0.1 call --abi AddingPurchasesDeBot.abi.json --sign AddingPurchasesDeBot.keys.json 0:d2c95e648ba1222cdf0b21298ecee3fbd9fc0dabab273e92683d911a69ba988f setCode ShoppingList.decode.json
Вызываем дебота
tonos-cli --url http://127.0.0.1 debot fetch 0:d2c95e648ba1222cdf0b21298ecee3fbd9fc0dabab273e92683d911a69ba988f
Ошибка, которую можно получить, если не перейти на иную работу со stateInit как в лекции:
Debot error: Contract execution was terminated with error: Unknown error, exit code: 55 (Bad StateInit cell for tvm_insert_pubkey. Data was not found.)

ИЗ ДЕВНЕТ СЕТИ
+ tondev sol compile ShoppingList.sol
+ tonos-cli decode stateinit ShoppingList.tvc --tvc
+ сохранить ShoppingList.decode.json



+ tondev sol compile AddingPurchasesDeBot.sol
+? tonos-cli genaddr AddingPurchasesDeBot.tvc AddingPurchasesDeBot.abi.json --genkey AddingPurchasesDeBot.keys.json > AddingPurchasesDeBot.log
Закинуть денег
вместо этого EXTRATON
Задеплоить
tonos-cli --url https://net.ton.dev deploy AddingPurchasesDeBot.tvc "{}" --sign AddingPurchasesDeBot.keys.json --abi AddingPurchasesDeBot.abi.json
+ bash
+ cat AddingPurchasesDeBot.abi.json | xxd -p -c 20000
exit
+ Записать dabi.json - в моем случае:
{
    "dabi": "7b0d0a0........d0a7d0d0a"
}
Установить dabi
tonos-cli --url https://net.ton.dev call 0:8499f371a4248b6f65c21a3d663d79186233063502a9382cc1e08340667899c9 setABI AddingPurchasesDeBot.dabi.json --sign AddingPurchasesDeBot.keys.json --abi AddingPurchasesDeBot.abi.json
!!!!!!!!!
предварительно сформировать ShoppingList.decode.json
tonos-cli --url https://net.ton.dev call --abi AddingPurchasesDeBot.abi.json --sign AddingPurchasesDeBot.keys.json 0:8499f371a4248b6f65c21a3d663d79186233063502a9382cc1e08340667899c9 buildStateInit ShoppingList.decode.json
Вызываем дебота
=- tonos-cli --url https://net.ton.dev debot --debug fetch 0:8499f371a4248b6f65c21a3d663d79186233063502a9382cc1e08340667899c9
https://web.ton.surf/debot?address=0%3A3f5d086d55927f318a051abc8d0042459d57814306ce2ff862e05ef9ab6054f4&net=devnet&restart=true

- мой публичный ключ: 6594a9978ba60315d9c71b0ad07710d320ed9850eddee3d12211417211bb454b