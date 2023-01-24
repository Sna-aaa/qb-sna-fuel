
local Translations = {
    info = {
        pickup_pump = "Coger/Dejar el combustible",
        buy_jerrican = "Comprar/Llenar el bidón",
        mount_pump = "[~g~E~w~] Colocar",
        dismount_pump = "[~r~E~w~] Desmontar",
        info_pump =  "Coloca el bidón en el vehículo para rellenar",
        refilling = "Servicio: %{value}L<br>Precio: $%{value2}",
        jerrican_refilling = "Servicio: %{value}L",
        recharging = "Servicio: %{value}Kw<br>Precio: $%{value2}",
        blip_fuel = "Gasolinera",
        blip_electric = "Cargador eléctrico",
    },
    message = {
        jerrican_refilled = "Bidón rellenado",
        jerrican_full = "Bidón lleno",
        jerrican_bought = "Bidón adquirido",
        no_money = "¡No tienes suficiente dinero!",
        must_be_driver = "Debes ser el conductor para realizar esta acción",
        to_far_away = "¡Te has alejado demasiado!"
    }
}

if GetConvar('qb_locale', 'en') == 'es' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
