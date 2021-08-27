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

package foundation.icon.btp.bmv.icon;

public class MTAException extends RuntimeException {
    public MTAException(String message) {
        super(message);
    }

    public MTAException(String message, Throwable cause) {
        super(message, cause);
    }

    public static class InvalidWitnessOldException extends MTAException {
        public InvalidWitnessOldException(String message) {
            super(message);
        }
    }

    public static class InvalidWitnessNewerException extends MTAException {
        public InvalidWitnessNewerException(String message) {
            super(message);
        }
    }
}
