/*
 * Copyright 2021 ICON Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package foundation.icon.btp.bmc;

import foundation.icon.jsonrpc.Address;
import foundation.icon.score.test.ScoreIntegrationTest;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInfo;

import java.math.BigInteger;
import java.util.*;
import java.util.function.Predicate;

import static org.junit.jupiter.api.Assertions.*;

public class RelayerManagementTest implements BMCIntegrationTest {

    static Address address = Address.of(tester);
    static BigInteger bond = BigInteger.valueOf(10);
    static String desc = "description";

    static Predicate<Relayer> relayerPredicate(Address address, BigInteger bond, String desc) {
        return (o) -> o.getAddr().equals(address) && o.getBond().equals(bond) && o.getDesc().equals(desc);
    }

    static boolean isExistsRelayer(Address address, BigInteger bond, String desc) {
        return ScoreIntegrationTest.contains(iconSpecific.getRelayers(),
                address.toString(), relayerPredicate(address, bond, desc));
    }

    static boolean isExistsRelayer(Address address) {
        return iconSpecific.getRelayers().containsKey(address.toString());
    }

    static void registerRelayer(BigInteger bond, String desc) {
        ScoreIntegrationTest.balanceCheck(address, bond.negate(),
                () -> ((ICONSpecificScoreClient)iconSpecificWithTester).registerRelayer(bond, desc));
        assertTrue(isExistsRelayer(address, bond, desc));
    }

    static void unregisterRelayer() {
        Relayer relayer = iconSpecificWithTester.getRelayers().get(address.toString());
        ScoreIntegrationTest.balanceCheck(address, relayer != null ? relayer.getBond().add(relayer.getReward()) : BigInteger.ZERO,
                iconSpecificWithTester::unregisterRelayer);
        assertFalse(isExistsRelayer(address));
    }

    static void clearRelayer() {
        if (isExistsRelayer(address)) {
            System.out.println("clear relayer address:"+ address);
            unregisterRelayer();
        }
    }

    @BeforeAll
    static void beforeAll() {
        BigInteger value = BigInteger.valueOf(100000000);
        ScoreIntegrationTest.balanceCheck(address, value,
                () -> bmcClient._transfer(address, value, null));
    }

    @AfterAll
    static void afterAll() {
        BigInteger value = bmcClientWithTester._balance(address);
        ScoreIntegrationTest.balanceCheck(address, value.negate(),
                () -> bmcClientWithTester._transfer(Address.of(bmcClient._wallet()), value, null));
    }

    @Override
    public void internalBeforeEach(TestInfo testInfo) {
        beforeDistributeRelayerTests(testInfo);
    }

    @Override
    public void internalAfterEach(TestInfo testInfo) {
        afterDistributeRelayerTests(testInfo);
    }

    @Override
    public void clearIfExists(TestInfo testInfo) {
        clearRelayer();
    }

    @Test
    void registerRelayerShouldSuccess() {
        registerRelayer(bond, desc);
    }

    @Test
    void registerRelayerShouldRevertAlreadyExists() {
        registerRelayer(bond, desc);

        AssertBMCException.assertUnknown(() -> registerRelayer(bond, desc));
    }

    @Test
    void registerRelayerShouldRevertNotEnoughBond() {
        AssertBMCException.assertUnknown(() -> registerRelayer(BigInteger.ZERO, desc));
    }

    @Test
    void unregisterRelayerShouldSuccess() {
        registerRelayer(bond, desc);

        unregisterRelayer();
    }

    @Test
    void unregisterRelayerShouldRevertNotExists() {
        AssertBMCException.assertUnknown(RelayerManagementTest::unregisterRelayer);
    }

    @Test
    void claimRelayerRewardShouldRevertNotExists() {
        AssertBMCException.assertUnknown(iconSpecific::claimRelayerReward);
    }

    static int relayerTerm = 2;
    static int relayerRewardRank = 3;
    static Integer[] sortedBonds = new Integer[]{4,3,3,2,1};
    private final List<ICONSpecificScoreClient> iconSpecificScoreClients = new ArrayList<>();
    private BigInteger sumOfReward = BigInteger.ZERO;
    private BigInteger sumOfBond = BigInteger.ZERO;

    ICONSpecificScoreClient newICONSpecificScoreClientWithTransfer(BigInteger value) {
        ICONSpecificScoreClient iconSpecificScoreClient = new ICONSpecificScoreClient(
                bmcClient.endpoint(), bmcClient._nid(), ScoreIntegrationTest.generateWallet(), bmcClient._address());
        Address address = Address.of(iconSpecificScoreClient._wallet());

        System.out.println("transfer to relayer address: "+ address+", value: "+value);
        bmcClient._transfer(address, value, null);
        return iconSpecificScoreClient;
    }

    Relayer registerRelayer(ICONSpecificScoreClient iconSpecificScoreClient, BigInteger bond, String desc) {
        Address address = Address.of(iconSpecificScoreClient._wallet());
        System.out.println("register relayer address: "+ address+", bond: "+bond+", desc:"+desc);
        ScoreIntegrationTest.balanceCheck(bmcClient._address(), bond,
                () -> iconSpecificScoreClient.registerRelayer(bond, desc));
        Relayer relayer = iconSpecific.getRelayers().get(address.toString());
        assertTrue(relayer != null && relayerPredicate(address, bond, desc).test(relayer));
        System.out.println("registered relayer "+relayer);
        return relayer;
    }

    void beforeDistributeRelayerTests(TestInfo testInfo) {
        if (isDistributeRelayerTests(testInfo)) {
            System.out.println("beforeDistributeRelayerTests start on "+testInfo.getDisplayName());
            assertEquals(0, iconSpecific.getRelayers().size(), "required relayers is empty");

            iconSpecific.setRelayerTerm(relayerTerm);
            iconSpecific.setRelayerRewardRank(relayerRewardRank);

            for (int i = 0; i < sortedBonds.length; i++) {
                BigInteger bond = BigInteger.valueOf(sortedBonds[i]);
                ICONSpecificScoreClient iconSpecificScoreClient = newICONSpecificScoreClientWithTransfer(bond);
                iconSpecificScoreClients.add(iconSpecificScoreClient);
                registerRelayer(iconSpecificScoreClient, bond, "Relayer "+i);

                if (i < relayerRewardRank) {
                    sumOfReward = sumOfReward.add(bond);
                }
                sumOfBond = sumOfBond.add(bond);
                assertEquals(sumOfBond, iconSpecific.getRelayersProperties().getBond());
            }

            iconSpecific.setNextRewardDistribution(0);

            //wait NextRewardDistribution
            ScoreIntegrationTest.waitByNumOfBlock(relayerTerm);
            System.out.println("beforeDistributeRelayerTests end on "+testInfo.getDisplayName());
        }
    }

    void afterDistributeRelayerTests(TestInfo testInfo) {
        if (isDistributeRelayerTests(testInfo)) {
            System.out.println("afterDistributeRelayerTests start on "+testInfo.getDisplayName());
            Address refund = Address.of(bmcClient._wallet());
            for (Map.Entry<String, Relayer> entry : iconSpecific.getRelayers().entrySet()) {
                Relayer relayer = entry.getValue();
                System.out.println("clear relayer "+ relayer);
                ScoreIntegrationTest.balanceCheck(refund, relayer.getBond().add(relayer.getReward()),
                        () -> iconSpecific.removeRelayer(relayer.getAddr(), refund));
                assertFalse(isExistsRelayer((Address) relayer.getAddr()));
            }
            iconSpecific.setRelayerTerm(RelayersProperties.DEFAULT.getRelayerTerm());
            iconSpecific.setRelayerRewardRank(RelayersProperties.DEFAULT.getRelayerRewardRank());
            iconSpecific.setNextRewardDistribution(0);

            iconSpecificScoreClients.clear();
            System.out.println("afterDistributeRelayerTests end on "+testInfo.getDisplayName());
        }
    }

    static boolean isDistributeRelayerTests(TestInfo testInfo) {
        return testInfo.getDisplayName().startsWith("distributeRelayerReward");
    }

    @Test
    void distributeRelayerRewardShouldDistributedAndHasCarryOver() {
        BigInteger notInTermBond = BigInteger.valueOf(sortedBonds[0]);
        ICONSpecificScoreClient notInTermClient = newICONSpecificScoreClientWithTransfer(notInTermBond);

        BigInteger carryOver = iconSpecific.getRelayersProperties().getCarryover();
        boolean carryOverExists = !carryOver.equals(BigInteger.ZERO);
        carryOver = carryOverExists ? carryOver : BigInteger.ONE;
        BigInteger reward = carryOverExists ? sumOfReward : sumOfReward.add(carryOver);
        System.out.println("transfer to BMC for reward "+ reward +
                (carryOverExists ? " existsCarryOver: " : " includeCarryOver: ") + carryOver);
        Address bmcAddress = bmcClient._address();
        ScoreIntegrationTest.balanceCheck(bmcAddress, reward,
                () -> bmcClient._transfer(bmcAddress, reward, null));

        registerRelayer(notInTermClient, notInTermBond, "notInTerm");

        System.out.println("distributeRelayerReward properties:"+ iconSpecific.getRelayersProperties());
        iconSpecific.distributeRelayerReward();
        RelayersProperties properties = iconSpecific.getRelayersProperties();
        BigInteger distributed = properties.getDistributed();
        assertEquals(sumOfReward, distributed);
        assertEquals(carryOver, properties.getCarryover());

        Map<String, Relayer> relayers = iconSpecific.getRelayers();
        for (int i = 0; i < sortedBonds.length; i++) {
            ICONSpecificScoreClient iconSpecificScoreClient = iconSpecificScoreClients.get(i);
            Relayer relayer = relayers.get(Address.of(iconSpecificScoreClient._wallet()).toString());
            if (i <  relayerRewardRank) {
                assertEquals(BigInteger.valueOf(sortedBonds[i]), relayer.getReward());

                System.out.println("claimRelayerRewardShouldSuccess relayerInRank "+relayer);
                ScoreIntegrationTest.balanceCheck((Address) relayer.getAddr(), relayer.getReward(),
                        iconSpecificScoreClient::claimRelayerReward);

                distributed = distributed.subtract(relayer.getReward());
                assertEquals(distributed, iconSpecific.getRelayersProperties().getDistributed());
            } else {
                assertEquals(BigInteger.ZERO, relayer.getReward());

                System.out.println("claimRelayerRewardShouldRevertRewardIsZero relayerNotInRank "+relayer);
                AssertBMCException.assertUnknown(iconSpecificScoreClient::claimRelayerReward);
            }
        }

        Relayer notInTermRelayer = relayers.get(Address.of(notInTermClient._wallet()).toString());
        assertEquals(BigInteger.ZERO, notInTermRelayer.getReward());
        System.out.println("claimRelayerRewardShouldRevertRewardIsZero notInTermRelayer "+notInTermRelayer);
        AssertBMCException.assertUnknown(notInTermClient::claimRelayerReward);

        assertEquals(BigInteger.ZERO, iconSpecific.getRelayersProperties().getDistributed());
    }

    @Test
    void sortTest() {
        List<Integer> bonds = Arrays.asList(Arrays.copyOf(sortedBonds, sortedBonds.length));
        Collections.shuffle(bonds);
        Relayer[] relayers = new Relayer[bonds.size()];
        for (int i = 0; i < bonds.size(); i++) {
            Relayer relayer = new Relayer();
            relayer.setDesc("Relayer "+i);
            relayer.setBond(BigInteger.valueOf(bonds.get(i)));
            relayer.setSince(1);
            relayer.setSinceExtra(i);
            relayers[i] = relayer;
        }
        Relayer[] sorted = Arrays.copyOf(relayers, relayers.length);
        Relayers.sortAsc(sorted);
        System.out.println("sorted: "+Arrays.toString(sorted));
        Relayer[] expected = Arrays.copyOf(relayers, relayers.length);
        Arrays.sort(expected, Relayers::compare);
        System.out.println("expected: "+Arrays.toString(expected));
        assertArrayEquals(expected, sorted);
    }
}
