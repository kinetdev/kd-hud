let elements = {};
let lastValues = {
    money: 0,
    bank: 0,
    black: 0
};

let playerStatus = {
    food: 100,
    water: 100,
    armor: 0,
    location: "Loading...",
    ammo: 0,
    inVehicle: false,
    speed: 0,
    fuel: 0,
    vehicleHealth: 100,
    engineHealth: 100,
    bodyHealth: 100,
    seatbelt: false
};

let jobCounts = {
    police: 0,
    medic: 0,
    mechanic: 0
};

let config = {};

$(document).ready(function() {
    elements = {
        playerHud: $('#player-hud'),
        playerName: $('#player-name'),
        playerId: $('#player-id .status-value'),
        job1: $('#job1'),
        job2: $('#job2'),
        money: $('#money'),
        bank: $('#bank'),
        blackMoney: $('#black-money'),
        
        serverLogo: $('.server-logo'),
        logoImage: $('.server-logo img'),
        logoGlow: $('.logo-glow'),
        
        foodStatus: $('#food-status .status-value'),
        waterStatus: $('#water-status .status-value'),
        armorStatus: $('#armor-status .status-value'),
        locationStatus: $('#location-status .status-text'),
        ammoStatus: $('#ammo-status .status-value'),
        
        vehicleStats: $('#vehicle-stats'),
        speedStatus: $('#speed-status .status-value'),
        fuelStatus: $('#fuel-status .status-value'),
        vehicleHealthStatus: $('#vehicle-health .status-value'),
        engineHealthStatus: $('#engine-health .status-value'),
        bodyHealthStatus: $('#body-health .status-value'),
        seatbeltStatus: $('#seatbelt-status'),
        seatbeltValue: $('#seatbelt-status .status-value'),
        
        jobCountContainer: $('.job-count-container'),
        policeCount: $('.job-count.police .count-number'),
        medicCount: $('.job-count.medic .count-number'),
        mechanicCount: $('.job-count.mechanic .count-number'),
        
        statusHubContainer: $('.status-hub-container'),
        foodItem: $('#food-status'),
        waterItem: $('#water-status'),
        armorItem: $('#armor-status'),
        fuelItem: $('#fuel-status'),
        vehicleHealthItem: $('#vehicle-health'),
        engineHealthItem: $('#engine-health'),
        bodyHealthItem: $('#body-health'),
        
        controlsGuide: $('.controls-guide')
    };
    
    window.addEventListener('message', function(event) {
        let data = event.data;
        
        if (data.action === 'updateHud') {
            updateHUD(data.data);
        } else if (data.action === 'toggleHud') {
            toggleHUD(data.show);
        } else if (data.action === 'updateStatus') {
            updateStatus(data.status);
        } else if (data.action === 'updateJobCounts') {
            updateJobCounts(data.counts);
        } else if (data.action === 'updateVehicle') {
            updateVehicleStatus(data.vehicle);
        } else if (data.action === 'toggleControlsGuide') {
            toggleControlsGuide(data.show);
        } else if (data.action === 'setConfig') {
            setConfig(data.config);
        } else if (data.action === 'updateSeatbelt') {
            updateSeatbelt(data.seatbelt);
        }
    });
    
    window.addEventListener('keydown', function(e) {
        if (e.key === 'h' || e.key === 'H') {
            toggleControlsGuide();
        }
    });
});

function setConfig(serverConfig) {
    if (!serverConfig) return;
    
    config = serverConfig;
    
    if (config.Logo) {
        if (config.Logo.url) {
            elements.logoImage.attr('src', config.Logo.url);
        }
        
        if (config.Logo.width) elements.logoImage.css('width', config.Logo.width);
        if (config.Logo.height) elements.logoImage.css('height', config.Logo.height);
        
        if (config.Logo.borderRadius) elements.logoImage.css('border-radius', config.Logo.borderRadius);
        if (config.Logo.borderColor) elements.logoImage.css('border-color', config.Logo.borderColor);
        if (config.Logo.borderWidth) elements.logoImage.css('border-width', config.Logo.borderWidth);
        
        if (config.Logo.animation === false) {
            elements.serverLogo.css('animation', 'none');
        }
        
        if (config.Logo.glow) {
            if (config.Logo.glow.enabled === false) {
                elements.logoGlow.hide();
            } else {
                if (config.Logo.glow.color) elements.logoGlow.css('background', `radial-gradient(circle, ${config.Logo.glow.color} 0%, rgba(255,255,255,0) 70%)`);
                if (config.Logo.glow.opacity) elements.logoGlow.css('opacity', config.Logo.glow.opacity);
            }
        }
    }
    
    if (config.JobCounters && config.JobCounters.enabled === false) {
        elements.jobCountContainer.hide();
    }
    
    if (config.StatusHub && config.StatusHub.enabled === false) {
        elements.statusHubContainer.hide();
    }
    
    if (config.ControlsGuide && config.ControlsGuide.enabled === false) {
        elements.controlsGuide.hide();
    }
}

function updateHUD(data) {
    if (!data) return;
    
    if (data.isShown) {
        elements.playerHud.show();
    } else {
        elements.playerHud.hide();
        return;
    }
    
    elements.playerName.text(data.playerName);
    elements.playerId.text(data.playerId);
    
    elements.job1.text(data.job1);
    elements.job2.text(data.job2);
    
    elements.money.text('$' + data.money);
    elements.bank.text('$' + data.bank);
    elements.blackMoney.text('$' + data.black);
    
    if (data.inVehicle && data.vehicleStats) {
        elements.vehicleStats.show();
        elements.speedStatus.text(data.vehicleStats.speed + ' km/h');
        elements.fuelStatus.text(data.vehicleStats.fuel + '%');
        elements.vehicleHealthStatus.text(data.vehicleStats.engineHealth + '%');
    } else {
        elements.vehicleStats.hide();
    }
    
    lastValues.money = parseInt(data.money.replace(/,/g, ''));
    lastValues.bank = parseInt(data.bank.replace(/,/g, ''));
    lastValues.black = parseInt(data.black.replace(/,/g, ''));
}

function updateStatus(status) {
    if (!status) return;
    
    if (status.food !== undefined) playerStatus.food = status.food;
    if (status.water !== undefined) playerStatus.water = status.water;
    if (status.armor !== undefined) playerStatus.armor = status.armor;
    if (status.location !== undefined) playerStatus.location = status.location;
    if (status.ammo !== undefined) playerStatus.ammo = status.ammo;
    
    updateFoodStatus(playerStatus.food);
    updateWaterStatus(playerStatus.water);
    updateArmorStatus(playerStatus.armor);
    updateLocationStatus(playerStatus.location);
    updateAmmoStatus(playerStatus.ammo);
}

function updateFoodStatus(value) {
    value = Math.max(0, Math.min(100, value));
    elements.foodStatus.text(value + '%');
    
    elements.foodItem.removeClass('low critical');
    if (value <= 30) elements.foodItem.addClass('critical');
    else if (value <= 50) elements.foodItem.addClass('low');
}

function updateWaterStatus(value) {
    value = Math.max(0, Math.min(100, value));
    elements.waterStatus.text(value + '%');
    
    elements.waterItem.removeClass('low critical');
    if (value <= 30) elements.waterItem.addClass('critical');
    else if (value <= 50) elements.waterItem.addClass('low');
}

function updateArmorStatus(value) {
    value = Math.max(0, Math.min(100, value));
    elements.armorStatus.text(value + '%');
}

function updateLocationStatus(location) {
    if (elements.locationStatus) {
        elements.locationStatus.text(location);
    }
}

function updateAmmoStatus(ammo) {
    if (ammo === undefined) return;
    
    elements.ammoStatus.text(ammo);
    
    if (ammo > 0) {
        elements.ammoStatus.parent().show();
    } else {
        elements.ammoStatus.parent().hide();
    }
}

function updateVehicleStatus(vehicle) {
    if (!vehicle) return;
    
    playerStatus.inVehicle = vehicle.inVehicle;
    
    if (vehicle.inVehicle) {
        if (elements.vehicleStats) {
            elements.vehicleStats.show();
        }
        
        if (vehicle.speed !== undefined) {
            playerStatus.speed = vehicle.speed;
            elements.speedStatus.text(vehicle.speed + ' km/h');
        }
        
        if (vehicle.fuel !== undefined) {
            playerStatus.fuel = vehicle.fuel;
            elements.fuelStatus.text(vehicle.fuel + '%');
            
            elements.fuelItem.removeClass('low critical');
            if (vehicle.fuel <= 10) elements.fuelItem.addClass('critical');
            else if (vehicle.fuel <= 25) elements.fuelItem.addClass('low');
        }
        
        if (vehicle.engineHealth !== undefined) {
            playerStatus.engineHealth = vehicle.engineHealth;
            elements.engineHealthStatus.text(vehicle.engineHealth + '%');
            
            elements.engineHealthItem.removeClass('low critical');
            if (vehicle.engineHealth <= 25) elements.engineHealthItem.addClass('critical');
            else if (vehicle.engineHealth <= 50) elements.engineHealthItem.addClass('low');
        }
        
        if (vehicle.bodyHealth !== undefined) {
            playerStatus.bodyHealth = vehicle.bodyHealth;
            elements.bodyHealthStatus.text(vehicle.bodyHealth + '%');
            
            elements.bodyHealthItem.removeClass('low critical');
            if (vehicle.bodyHealth <= 25) elements.bodyHealthItem.addClass('critical');
            else if (vehicle.bodyHealth <= 50) elements.bodyHealthItem.addClass('low');
        }
    } else {
        if (elements.vehicleStats) {
            elements.vehicleStats.hide();
        }
    }
}

function updateSeatbelt(isOn) {
    playerStatus.seatbelt = isOn;
    
    if (elements.seatbeltStatus) {
        if (isOn) {
            elements.seatbeltStatus.removeClass('off').addClass('on');
            elements.seatbeltValue.text('BẬT');
        } else {
            elements.seatbeltStatus.removeClass('on').addClass('off');
            elements.seatbeltValue.text('TẮT');
        }
    }
}

function updateJobCounts(counts) {
    if (!counts) return;
    
    if (counts.police !== undefined) {
        jobCounts.police = counts.police;
        elements.policeCount.text(counts.police);
    }
    
    if (counts.medic !== undefined) {
        jobCounts.medic = counts.medic;
        elements.medicCount.text(counts.medic);
    }
    
    if (counts.mechanic !== undefined) {
        jobCounts.mechanic = counts.mechanic;
        elements.mechanicCount.text(counts.mechanic);
    }
}

function toggleControlsGuide(show) {
    if (show === undefined) {
        elements.controlsGuide.toggle();
    } else {
        show ? elements.controlsGuide.show() : elements.controlsGuide.hide();
    }
}

function formatNumber(num) {
    return num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
}