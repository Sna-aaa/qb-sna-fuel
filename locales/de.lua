local Translations = {
    info = {
        pickup_pump = "Zapfpistole Nehmen/Zurückgeben",
        buy_jerrican = "Benzinkanister Kaufen/Nachfüllen",
        mount_pump = "[~g~E~w~] Einführen",
        dismount_pump = "[~r~E~w~] Entfernen",
        info_pump = "Zapfpistole zum Tanken ins Fahrzeug einführen",
        refilling = "Treibstoff: %{value}L<br>Preis: $%{value2}",
        jerrican_refilling = "Treibstoff: %{value}L",
        recharging = "Strom: %{value}Kw<br>Preis: $%{value2}",
        blip_fuel = "Tankstelle",
        blip_electric = "Ladegerät",
    },
    message = {
        jerrican_refilled = "Benzinkanister nachgefüllt",
        jerrican_full = "Benzinkanister voll",
        jerrican_bought = "Benzinkanister gekauft",
        no_money = "Sie haben nicht genug Geld",
        must_be_driver = "Sie müssen der Fahrer sein, um das zu tun",
        to_far_away = "Du bist zu weit weg, der Schlauch ist gerissen"
    }
}

if GetConvar('qb_locale', 'en') == 'de' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
