local Translations = {
    info = {
        pickup_pump = "Prendre/Remettre le pistolet",
        buy_jerrican = "Acheter/Remplir Bidon",
        mount_pump = "[~g~E~w~] Placer",
        dismount_pump = "[~r~E~w~] Retirer",
        info_pump =  "Placez le pistolet sur le véhicule pour faire le plein",
        refilling = "Service: %{value}L<br>Prix: $%{value2}",
        jerrican_refilling = "Service: %{value}L",
        recharging = "Service: %{value}Kw<br>Prix: $%{value2}",
        blip_fuel = "Station service",
        blip_electric = "Chargeur electrique",
    },
    message = {
        jerrican_refilled = "Bidon rempli",
        jerrican_full = "Bidon plein",
        jerrican_bought = "Vous avez acheté un bidon",
        no_money = "Vous n'avez pas assez d'argent",
        must_be_driver = "Vous devez etre le conducteur pour faire cela",
        to_far_away = "Vous etes trop loin, le tuyau a cassé"
    }
}

if GetConvar('qb_locale', 'en') == 'fr' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
