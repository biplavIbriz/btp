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

package foundation.icon.btp.lib;

import score.Address;
import score.Context;

import java.math.BigInteger;

public final class OwnerManagerScoreInterface implements OwnerManager {
  protected final Address address;

  protected final BigInteger valueForPayable;

  public OwnerManagerScoreInterface(Address address) {
    this.address = address;
    this.valueForPayable = null;
  }

  public OwnerManagerScoreInterface(Address address, BigInteger valueForPayable) {
    this.address = address;
    this.valueForPayable = valueForPayable;
  }

  public Address _getAddress() {
    return this.address;
  }

  public OwnerManagerScoreInterface _payable(BigInteger valueForPayable) {
    return new OwnerManagerScoreInterface(address,valueForPayable);
  }

  public OwnerManagerScoreInterface _payable(long valueForPayable) {
    return this._payable(BigInteger.valueOf(valueForPayable));
  }

  public BigInteger _getICX() {
    return this.valueForPayable;
  }

  @Override
  public void addOwner(Address _addr) {
    Context.call(this.address, "addOwner", _addr);
  }

  @Override
  public void removeOwner(Address _addr) {
    Context.call(this.address, "removeOwner", _addr);
  }

  @Override
  public Address[] getOwners() {
    return Context.call(Address[].class, this.address, "getOwners");
  }

  @Override
  public boolean isOwner(Address _addr) {
    return Context.call(Boolean.class, this.address, "isOwner", _addr);
  }
}
