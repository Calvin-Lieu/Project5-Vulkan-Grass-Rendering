#include "Scene.h"
#include "BufferUtils.h"

Scene::Scene(Device* device) : device(device) {
    BufferUtils::CreateBuffer(device, sizeof(Time), VK_BUFFER_USAGE_UNIFORM_BUFFER_BIT, VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT | VK_MEMORY_PROPERTY_HOST_COHERENT_BIT, timeBuffer, timeBufferMemory);
    vkMapMemory(device->GetVkDevice(), timeBufferMemory, 0, sizeof(Time), 0, &mappedData);
    memcpy(mappedData, &time, sizeof(Time));
}

const std::vector<Model*>& Scene::GetModels() const {
    return models;
}

const std::vector<Blades*>& Scene::GetBlades() const {
  return blades;
}

void Scene::AddModel(Model* model) {
    models.push_back(model);
}

void Scene::AddBlades(Blades* blades) {
  this->blades.push_back(blades);
}

void Scene::UpdateTime() {
    using namespace std::chrono;

    static bool first = true;
    static high_resolution_clock::time_point lastTime = high_resolution_clock::now();

    high_resolution_clock::time_point currentTime = high_resolution_clock::now();
    duration<float> nextDeltaTime = duration_cast<duration<float>>(currentTime - lastTime);
    lastTime = currentTime;

    float dt = nextDeltaTime.count();
    dt = (dt < 0.0f ? 0.0f : (dt > 0.033f ? 0.033f : dt)); // clamp
    static float smoothedDt = dt;
    smoothedDt = 0.9f * smoothedDt + 0.1f * dt; // exponential smoothing
    time.deltaTime = smoothedDt;
    time.totalTime += smoothedDt;

    memcpy(mappedData, &time, sizeof(Time));
}


VkBuffer Scene::GetTimeBuffer() const {
    return timeBuffer;
}

Scene::~Scene() {
    vkUnmapMemory(device->GetVkDevice(), timeBufferMemory);
    vkDestroyBuffer(device->GetVkDevice(), timeBuffer, nullptr);
    vkFreeMemory(device->GetVkDevice(), timeBufferMemory, nullptr);
}
