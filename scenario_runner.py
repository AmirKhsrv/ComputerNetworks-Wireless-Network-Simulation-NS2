import os
from matplotlib import pyplot as plt


class ScenarioGenerator(object):
    bandwidth_list = [1.5, 55, 155]
    default_packet_size = 256
    default_error_rate = 0.000001

    def __init__(self):
        self.bandwidth_scenario, self.packet_size_scenario, self.error_rate_scenario = [
            self.generate_bandwidth_scenario(),
            self.generate_packet_size_scenario(),
            self.generate_error_rate_scenario()
        ]

    def generate_bandwidth_scenario(self):
        gen_lst = []
        for bandwidth in self.bandwidth_list:
            gen_lst.append([bandwidth, self.default_packet_size, self.default_error_rate * 10])
        return gen_lst

    def generate_packet_size_scenario(self):
        gen_lst = []
        for x in range(1, 31, 3):
            gen_lst.append([self.bandwidth_list[0], self.default_packet_size * x, self.default_error_rate*10])
        return gen_lst
            
    def generate_error_rate_scenario(self):
        gen_lst = []
        for x in range(1, 11):
            gen_lst.append([self.bandwidth_list[0], self.default_packet_size, self.default_error_rate * x])
        return gen_lst


class ScenarioRunner(object):

    def __init__(self, scenario_gen):
        self.scenario_gen = scenario_gen

    def run(self):
        results = self.get_scenario_type_result(self.scenario_gen.bandwidth_scenario)
        self.plot_result(self.scenario_gen.bandwidth_list, 'Bandwidth Scenario', 'Mbps', results)

        results = self.get_scenario_type_result(self.scenario_gen.packet_size_scenario)
        self.plot_result([item[1] for item in self.scenario_gen.packet_size_scenario], 'PacketSize Scenario', 'Byte', results)
        print([item[1] for item in self.scenario_gen.packet_size_scenario])

        results = self.get_scenario_type_result(self.scenario_gen.error_rate_scenario)
        self.plot_result([item[2] for item in self.scenario_gen.error_rate_scenario], 'Error Rate Scenario', 'Error Rate', results)

        plt.show()

    @staticmethod
    def get_scenario_type_result(scenario_type):
        results = []
        for scenario in scenario_type:
            print(f"exec ns CA2.tcl {scenario[0]} {scenario[1]} {scenario[2]}")
            os.system("ns CA2.tcl " + str(scenario[0]) + " " + str(scenario[1]) + " " + str(scenario[2]))
            stream = os.popen("python3 parse_input.py sim_trace.tr")
            results.append(tuple(map(float, stream.read().split(' '))))
            stream.close()
        return results

    def plot_result(self, scenario_list, subtitle, xlabel, result):
        fig = plt.figure(figsize=(5, 10))
        gs = fig.add_gridspec(3, hspace=0.5)
        axes = gs.subplots()
        fig.suptitle(subtitle)
        axes[0].plot(scenario_list, [item[0] for item in result], '-o')
        axes[0].set_title("Throughput")
        axes[0].set_xlabel(xlabel)
        axes[0].set_ylabel("Kbps")

        axes[1].plot(scenario_list, [item[1] for item in result], '-o')
        axes[1].set_title("Packet Transfer Ratio")
        axes[1].set_xlabel(xlabel)
        axes[1].set_ylabel("percent")

        axes[2].plot(scenario_list, [item[2] for item in result], '-o')
        axes[2].set_title("Avg E2E Delay")
        axes[2].set_xlabel(xlabel)
        axes[2].set_ylabel("sec")


scenario_gen = ScenarioGenerator()
runner = ScenarioRunner(scenario_gen)
runner.run()
