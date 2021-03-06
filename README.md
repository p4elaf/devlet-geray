# Disbalancer terraform ASG

## Що це?
Автоматизований скрипт по деплою 10 (в дефолті, так-то можна і більше) інстансів з disbalancer'ом.  
Включає в себе ~~блекджек та повій~~ ProtonVPN докер контейнер та підключенй в його нетворк контейнер disbalancer'у.  
Disbalancer контейнер буде зібранний в останній на момент розгортання версії.  
Розгортається все це на aws spot інстансах, що дає економію по грошах приблизно в 60-70%. 

## Як його та куди?
0 Попередні умови:
- Акаунт ProtonVPN 2 рівня, план Plus (дає 10 одночасних підключень та нормальну швидкість тунелю)
- Акаунт у AWS та налаштований профіль AWS cli (https://aws.amazon.com/cli/)
- Встановлений terraform останньої версії (https://www.terraform.io/)

1 Йдемо в файл variables.tf, замінюємо на свої значення змінних:
- region - бажаний регіон розгортання, дефолтовий - us-east-1
- aws_profile_name - ім'я профілю aws cli, дефолтовий - default
- proton_user, proton_password - ім'я та пароль згенеровані в адмінці ProtonVPN (https://account.protonvpn.com/account#openvpn, поля OpenVPN / IKEv2 username )
- вайтліст IP адрес доступу до ваших нових інстансів по ssh, дефолт - звідки завгодно
- devlet_geray_key - ваш паблік ssh ключ в pem форматі, якщо плануєте ходити на інстанси та дивитися як там справи
- instances_size - розмір тачок, дефолт - t3a.micro, два контейнери тягне без проблем
- asg_capacity - кількість інстансів, дефолт - 10 (бо згадане вище обмеження плану Plus від ProtonVpn)
- environment, vpc_cidr_block, enable_dns_hostnames, vpc_subnet1_cidr_block - можна не чіпати
- map_public_ip_on_launch - не можна чіпати

2 Деплой:
- Йдемо в папку з репозиторієм командним рядком та виконуємо там три команди:
- terraform init - скачає все необхідне для роботи
- terraform plan - дивимося, що воно буде робити
- terraform apply - дивимося ще раз і, якщо нам подобається те що бачимо, відповідаємо yes, тиснемо Enter
- чекаємо 2 хв
- готово, руський корабль пливе куди треба

3 Гроші:
- Коштує вся ця краса менше $3 на день включно з трафіком.  
Тут залежить від вибраного вами регіону, його розміру, навантаження та доступності дешевих spot інтсансів.  
Саме тому в дефолті обраний us-east-1 - самий великий регіон з купою ресурсів.

4 Скінчилися гроші, все пійшло на ЗСУ, хочемо все видалити:
- Йдемо в той самий фолдер та виконуємо там комманду terraform destroy, і як вирішили остаточно, віповідаємо yes та тиснемо Enter
