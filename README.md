# UART
A Universal Asynchronous Receiver/Transmitter (UART) is a block of circuitry responsible for implementing serial communication. It is a Full Duplex protocol that supports data transmission in both directions
simultaneously.

The design includes:
* _Transmitting UART_ converts parallel data from the master device (eg. CPU) into serial form and transmit in serial to receiving UART.
* _Receiving UART_ will then convert the serial data back into parallel data for the receiving device.
