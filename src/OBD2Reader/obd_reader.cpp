#include <iostream>
#include <string>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <vector>

int set_interface_attribs(int fd, int speed) {
    struct termios tty{};
    if (tcgetattr(fd, &tty) != 0) return -1;

    cfsetospeed(&tty, speed);
    cfsetispeed(&tty, speed);

    tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;
    tty.c_iflag &= ~IGNBRK;
    tty.c_lflag = 0;
    tty.c_oflag = 0;
    tty.c_cc[VMIN] = 0;
    tty.c_cc[VTIME] = 10;

    tty.c_iflag &= ~(IXON | IXOFF | IXANY);
    tty.c_cflag |= (CLOCAL | CREAD);
    tty.c_cflag &= ~(PARENB | PARODD);
    tty.c_cflag &= ~CSTOPB;
    tty.c_cflag &= ~CRTSCTS;

    return tcsetattr(fd, TCSANOW, &tty);
}

std::string send_cmd(int fd, const std::string &cmd) {
    std::string full_cmd = cmd + "\r";
    write(fd, full_cmd.c_str(), full_cmd.size());
    usleep(150000);

    char buffer[1024];
    int n = read(fd, buffer, sizeof(buffer));
    return std::string(buffer, n);
}

int hex2int(const std::string &s) {
    return strtol(s.c_str(), nullptr, 16);
}

double parseAFR(const std::string &resp) {
    // Find bytes: Example response: "41 14 A1 B2"
    size_t pos = resp.find("41 14");
    if (pos == std::string::npos) return -1;

    std::string A_str = resp.substr(pos + 6, 2);
    std::string B_str = resp.substr(pos + 9, 2);

    int A = hex2int(A_str);
    int B = hex2int(B_str);
    int value = A * 256 + B;

    return 14.7 * (2.0 * value / 65535.0);
}

int main() {
    int fd = open("/dev/ttyUSB0", O_RDWR | O_NOCTTY | O_SYNC);
    if (fd < 0) {
        std::cerr << "Cannot open /dev/ttyUSB0\n";
        return 1;
    }

    set_interface_attribs(fd, B38400); // Default ELM327 baud

    // ELM initialization
    send_cmd(fd, "ATZ");
    sleep(1);
    send_cmd(fd, "ATE0");
    send_cmd(fd, "ATL0");
    send_cmd(fd, "ATS0");
    send_cmd(fd, "ATH0");
    send_cmd(fd, "ATSP0");

    while (true) {
        std::cout << "---------------------------------\n";

        // Example PIDs
        std::cout << "RPM: " << send_cmd(fd, "010C");
        std::cout << "Speed: " << send_cmd(fd, "010D");
        std::cout << "Coolant temp: " << send_cmd(fd, "0105");
        std::cout << "Throttle pos: " << send_cmd(fd, "0111");
        std::cout << "MAF: " << send_cmd(fd, "0110");
        std::cout << "Intake temp: " << send_cmd(fd, "010F");

        // AFR (Wideband)
        std::string afr_resp = send_cmd(fd, "0114");
        double afr = parseAFR(afr_resp);
        std::cout << "AFR (0114): " << afr << " (" << afr_resp << ")\n";

        sleep(1); // 1 Hz update rate
    }

    close(fd);
    return 0;
}
