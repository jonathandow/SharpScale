from bleak import BleakServer
import asyncio

class SimpleService:
    UUID = "77670a58-1cb4-4652-ae7d-2492776d303d"

    def __init__(self):
        self.value = bytearray("Data to send", 'utf-8')

    async def read(self):
        return self.value

    async def write(self, value):
        self.value = value
        print(f"Write request received: {value}")

async def main():
    service = SimpleService()
    async with BleakServer(service, service_uuids=[service.UUID]) as server:
        await server.start()
        print("Server is now running")
        await asyncio.sleep(float("inf")) 

if __name__ == "__main__":
    asyncio.run(main())
