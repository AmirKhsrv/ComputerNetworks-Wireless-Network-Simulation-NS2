import sys
from enums import *


def merge_two_dicts(x, y):
    z = x.copy()   # start with keys and values of x
    z.update(y)    # modifies z with keys and values of y
    return z


class Parser(object):

    def __init__(self, argv):
        self.argv = argv

    def get_file_lines(self):
        lines = []
        with open(self.argv[1], 'r') as f:
            lines = f.readlines()
        return lines

    @staticmethod
    def filter_trace(src, dst, type, trace_info):
        def predicate(line):
            if type == 'r':
                node = dst
            else:
                node = src
            if (line[0] == type) and ('_' + node + '_ AGT ' in line):
                src_dst_info = line.split('] ------- [')[1].split(']')[0].split(' ')
                if src_dst_info[0].split(':')[0] == src and src_dst_info[1].split(':')[0] == dst:
                    return True
            return False

        return filter(predicate, trace_info)

    @staticmethod
    def extract_info(line):
        parts = line.split(' ')
        return (
            int(parts[6]),
            (float(parts[1]),
             int(parts[8]))
        )

    def get_packets_info(self, src, dst, type, trace_info):
        return dict(map(self.extract_info, self.filter_trace(src, dst, type, trace_info)))

    @staticmethod
    def get_throughput(received, sent):
        transfer_size, max_time, min_time = 0.0, 0.0, 100.0
        for packet in received.items():
            packet_sent = sent[packet[0]]
            transfer_size += packet_sent[1]
            min_time = min(min_time, packet_sent[0])
            max_time = max(max_time, packet[1][0])

        return (8 * transfer_size / 1000) / (max_time - min_time)

    @staticmethod
    def get_packet_transfer_ratio(received, sent):
        return 100 * len(received) / len(sent)

    @staticmethod
    def get_average_delay(received, sent):
        sum_of_delays = 0.0
        for packet in received.items():
            packet_sentent = sent[packet[0]]
            sum_of_delays += packet[1][0] - packet_sentent[0]

        return sum_of_delays / len(received)

    def parse(self):
        file_lines = self.get_file_lines()

        received = {}
        for src_to_dst_received in RECEIVED:
            received = merge_two_dicts(received, self.get_packets_info(*src_to_dst_received, file_lines))

        sent = {}
        for src_to_dst_sent in SENT:
            sent = merge_two_dicts(sent, self.get_packets_info(*src_to_dst_sent, file_lines))

        throughput = self.get_throughput(received, sent)
        packet_transfer_ratio = self.get_packet_transfer_ratio(received, sent)
        average_e2e_delay = self.get_average_delay(received, sent)

        print(throughput, packet_transfer_ratio, average_e2e_delay, end='')


parser = Parser(sys.argv)
parser.parse()
