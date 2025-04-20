// Cache DOM elements
let elements = {};
let lastValues = {
    money: 0,
    bank: 0,
    black: 0
};

// Player status data
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

// Job counts data
let jobCounts = {
    police: 0,
    medic: 0,
    mechanic: 0
};

// Config data received from client
let config = {};

// Initialize when document is ready
$(document).ready(function() {
    // Store DOM element references for better performance
    elements = {
        // Main HUD elements
        playerHud: $('#player-hud'),
        playerName: $('#player-name'),
        playerId: $('#player-id .status-value'),
        job1: $('#job1'),
        job2: $('#job2'),
        money: $('#money'),
        bank: $('#bank'),
        blackMoney: $('#black-money'),
        
        // Logo elements
        serverLogo: $('.server-logo'),
        logoImage: $('.server-logo img'),
        logoGlow: $('.logo-glow'),
        
        // Status elements
        foodStatus: $('#food-status .status-value'),
        waterStatus: $('#water-status .status-value'),
        armorStatus: $('#armor-status .status-value'),
        locationStatus: $('#location-status .status-text'),
        ammoStatus: $('#ammo-status .status-value'),
        
        // Vehicle elements
        vehicleStats: $('#vehicle-stats'),
        speedStatus: $('#speed-status .status-value'),
        fuelStatus: $('#fuel-status .status-value'),
        vehicleHealthStatus: $('#vehicle-health .status-value'),
        engineHealthStatus: $('#engine-health .status-value'),
        bodyHealthStatus: $('#body-health .status-value'),
        seatbeltStatus: $('#seatbelt-status'),
        seatbeltValue: $('#seatbelt-status .status-value'),
        
        // Job count elements
        jobCountContainer: $('.job-count-container'),
        policeCount: $('.job-count.police .count-number'),
        medicCount: $('.job-count.medic .count-number'),
        mechanicCount: $('.job-count.mechanic .count-number'),
        
        // Status item containers
        statusHubContainer: $('.status-hub-container'),
        foodItem: $('#food-status'),
        waterItem: $('#water-status'),
        armorItem: $('#armor-status'),
        fuelItem: $('#fuel-status'),
        vehicleHealthItem: $('#vehicle-health'),
        engineHealthItem: $('#engine-health'),
        bodyHealthItem: $('#body-health'),
        
        // Controls guide
        controlsGuide: $('.controls-guide')
    };
    
    // Listen for NUI messages from the game
    window.addEventListener('message', function(event) {
        let data = event.data;
        
        // Handle different NUI actions
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
    
    // Initialize key shortcuts
    window.addEventListener('keydown', function(e) {
        if (e.key === 'h' || e.key === 'H') {
            toggleControlsGuide();
        }
    });
});

// Set config values received from client
function setConfig(serverConfig) {
    if (!serverConfig) return;
    
    config = serverConfig;
    
    // Apply logo config
    if (config.Logo) {
        // Update logo image source if provided
        if (config.Logo.url) {
            elements.logoImage.attr('src', config.Logo.url);
        }
        
        // Update logo size
        if (config.Logo.width) elements.logoImage.css('width', config.Logo.width);
        if (config.Logo.height) elements.logoImage.css('height', config.Logo.height);
        
        // Update logo styling
        if (config.Logo.borderRadius) elements.logoImage.css('border-radius', config.Logo.borderRadius);
        if (config.Logo.borderColor) elements.logoImage.css('border-color', config.Logo.borderColor);
        if (config.Logo.borderWidth) elements.logoImage.css('border-width', config.Logo.borderWidth);
        
        // Toggle animation
        if (config.Logo.animation === false) {
            elements.serverLogo.css('animation', 'none');
        }
        
        // Configure glow effect
        if (config.Logo.glow) {
            if (config.Logo.glow.enabled === false) {
                elements.logoGlow.hide();
            } else {
                if (config.Logo.glow.color) elements.logoGlow.css('background', `radial-gradient(circle, ${config.Logo.glow.color} 0%, rgba(255,255,255,0) 70%)`);
                if (config.Logo.glow.opacity) elements.logoGlow.css('opacity', config.Logo.glow.opacity);
            }
        }
    }
    
    // Handle feature toggles
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

// Update HUD with player data
function updateHUD(data) {
    // Only proceed if we have data
    if (!data) return;
    
    // Show or hide HUD
    if (data.isShown) {
        elements.playerHud.show();
    } else {
        elements.playerHud.hide();
        return;
    }
    
    // Update player info
    elements.playerName.text(data.playerName);
    elements.playerId.text(data.playerId);
    
    // Update jobs
    elements.job1.text(data.job1);
    elements.job2.text(data.job2);
    
    // Update money values
    elements.money.text('$' + data.money);
    elements.bank.text('$' + data.bank);
    elements.blackMoney.text('$' + data.black);
    
    // Update vehicle stats if in vehicle
    if (data.inVehicle && data.vehicleStats) {
        elements.vehicleStats.show();
        elements.speedStatus.text(data.vehicleStats.speed + ' km/h');
        elements.fuelStatus.text(data.vehicleStats.fuel + '%');
        elements.vehicleHealthStatus.text(data.vehicleStats.engineHealth + '%');
    } else {
        elements.vehicleStats.hide();
    }
    
    // Update last values for next comparison
    lastValues.money = parseInt(data.money.replace(/,/g, ''));
    lastValues.bank = parseInt(data.bank.replace(/,/g, ''));
    lastValues.black = parseInt(data.black.replace(/,/g, ''));
}

// Update player status indicators
function updateStatus(status) {
    if (!status) return;
    
    // Update stored status
    if (status.food !== undefined) playerStatus.food = status.food;
    if (status.water !== undefined) playerStatus.water = status.water;
    if (status.armor !== undefined) playerStatus.armor = status.armor;
    if (status.location !== undefined) playerStatus.location = status.location;
    if (status.ammo !== undefined) playerStatus.ammo = status.ammo;
    
    // Update UI elements
    updateFoodStatus(playerStatus.food);
    updateWaterStatus(playerStatus.water);
    updateArmorStatus(playerStatus.armor);
    updateLocationStatus(playerStatus.location);
    updateAmmoStatus(playerStatus.ammo);
}

// Update food status
function updateFoodStatus(value) {
    // Ensure value is between 0 and 100
    value = Math.max(0, Math.min(100, value));
    elements.foodStatus.text(value + '%');
    
    // Update warning classes
    elements.foodItem.removeClass('low critical');
    if (value <= 30) elements.foodItem.addClass('critical');
    else if (value <= 50) elements.foodItem.addClass('low');
}

// Update water status
function updateWaterStatus(value) {
    // Ensure value is between 0 and 100
    value = Math.max(0, Math.min(100, value));
    elements.waterStatus.text(value + '%');
    
    // Update warning classes
    elements.waterItem.removeClass('low critical');
    if (value <= 30) elements.waterItem.addClass('critical');
    else if (value <= 50) elements.waterItem.addClass('low');
}

// Update armor status
function updateArmorStatus(value) {
    elements.armorStatus.text(value + '%');
    
    // Không thêm class để tránh nhấp nháy
    elements.armorItem.removeClass('low critical');
}

// Update location status
function updateLocationStatus(location) {
    elements.locationStatus.text(location);
}

// Update ammo status
function updateAmmoStatus(ammo) {
    if (ammo === undefined) return;
    
    elements.ammoStatus.text(ammo);
    
    // Không thêm class để tránh nhấp nháy
    elements.ammoItem = $('#ammo-status');
    elements.ammoItem.removeClass('low critical');
}

// Update vehicle status
function updateVehicleStatus(vehicle) {
    if (!vehicle) return;
    
    // Update stored status
    if (vehicle.speed !== undefined) playerStatus.speed = vehicle.speed;
    if (vehicle.fuel !== undefined) playerStatus.fuel = vehicle.fuel;
    if (vehicle.engineHealth !== undefined) playerStatus.engineHealth = vehicle.engineHealth;
    if (vehicle.bodyHealth !== undefined) playerStatus.bodyHealth = vehicle.bodyHealth;
    if (vehicle.seatbelt !== undefined) playerStatus.seatbelt = vehicle.seatbelt;
    
    // Show/hide vehicle stats
    if (vehicle.inVehicle) {
        elements.vehicleStats.show();
    } else {
        elements.vehicleStats.hide();
        return;
    }
    
    // Update UI elements
    elements.speedStatus.text(playerStatus.speed + ' km/h');
    elements.fuelStatus.text(playerStatus.fuel + '%');
    
    // Update engine health
    let engineHealth = Math.max(0, Math.min(100, playerStatus.engineHealth));
    elements.engineHealthStatus.text(engineHealth + '%');
    
    // Update body health
    let bodyHealth = Math.max(0, Math.min(100, playerStatus.bodyHealth));
    elements.bodyHealthStatus.text(bodyHealth + '%');
    
    // Update seatbelt status
    updateSeatbelt(playerStatus.seatbelt);
    
    // Update warning classes
    elements.fuelItem.removeClass('low critical');
    if (playerStatus.fuel <= 30) elements.fuelItem.addClass('critical');
    else if (playerStatus.fuel <= 50) elements.fuelItem.addClass('low');
    
    // Update engine health warning
    elements.engineHealthItem.removeClass('low critical');
    if (engineHealth <= 30) elements.engineHealthItem.addClass('critical');
    else if (engineHealth <= 50) elements.engineHealthItem.addClass('low');
    
    // Update body health warning
    elements.bodyHealthItem.removeClass('low critical');
    if (bodyHealth <= 30) elements.bodyHealthItem.addClass('critical');
    else if (bodyHealth <= 50) elements.bodyHealthItem.addClass('low');
}

// Update seatbelt status
function updateSeatbelt(isOn) {
    playerStatus.seatbelt = isOn;
    
    elements.seatbeltStatus.removeClass('on off');
    if (isOn) {
        elements.seatbeltStatus.addClass('on');
        elements.seatbeltValue.text('BẬT');
    } else {
        elements.seatbeltStatus.addClass('off');
        elements.seatbeltValue.text('TẮT');
    }
}

// Update job counts
function updateJobCounts(counts) {
    if (!counts) return;
    
    // Update stored counts
    if (counts.police !== undefined) jobCounts.police = counts.police;
    if (counts.medic !== undefined) jobCounts.medic = counts.medic;
    if (counts.mechanic !== undefined) jobCounts.mechanic = counts.mechanic;
    
    // Update UI elements
    elements.policeCount.text(jobCounts.police);
    elements.medicCount.text(jobCounts.medic);
    elements.mechanicCount.text(jobCounts.mechanic);
}

// Toggle controls guide
function toggleControlsGuide(show) {
    if (show) {
        elements.controlsGuide.show();
    } else {
        elements.controlsGuide.hide();
    }
}

// Format number with commas
function formatNumber(num) {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}