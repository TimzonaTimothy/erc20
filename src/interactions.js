import {React, useState} from 'react'
import {ethers} from 'ethers'
import './styles.css';

const Interactions = (props) => {

	const [transferHash, setTransferHash] = useState();
	const [alltransactions, setAllTransactions] = useState([]);

    const mintTokenHandler = async (e) => {
		e.preventDefault();
		let mAmount = e.target.mintAmount.value;
		

		let txt = await props.contract.mint(mAmount);
		console.log(txt);
		setTransferHash("Mint confirmation hash: " + txt.hash);
	}

    const approvetxnHandler = async (e) => {
		e.preventDefault();
		let txid = e.target.txnId.value;
		

		let txt = await props.contract.approvetxn(txid);
		console.log(txt);
		setTransferHash("Approve confirmation hash: " + txt.hash);
	}

    const executeHandler = async (e) => {
		e.preventDefault();
		let extxn = e.target.executetxn.value;
		

		let txt = await props.contract.execute(extxn);
		console.log(txt);
		setTransferHash("Approve confirmation hash: " + txt.hash);
	}

	const transferHandler = async (e) => {
		e.preventDefault();
		let transferAmount = e.target.sendAmount.value;
		let recieverAddress = e.target.recieverAddress.value;

		let txt = await props.contract.transfer(recieverAddress, transferAmount);
		console.log(txt);
		setTransferHash("Transfer confirmation hash: " + txt.hash);
	}

	const getTransactions = async () => {
		let transactions = await props.contract.getTransactionsByAddress();
        console.log(transactions);
        

        let transactioncleaned = [];
        transactions.forEach(transaction => {
          transactioncleaned.push({
            address: transaction.to,
            amount: transaction.amount,
			data: transaction.data,
            executed: transaction.executed,
          });
        });
		setAllTransactions(transactioncleaned);
        console.log(transactions);
	}
	getTransactions();

	return (
			<div className="interactionsCard">
                <form onSubmit={mintTokenHandler}>
                    <div>
                        <h3>Mint Token</h3>
                        <p>Enter Amount</p>
                        <input type='number' id='mintAmount' min='0' step='1' placeholder=""/>

						<button type='submit' className="button">Mint</button>
                    </div>
                </form>

                <form onSubmit={approvetxnHandler}>
                    <div>
                        <h3>Approve Mint</h3>
                        <p>Enter transaction ID</p>
                        <input type='number' id='txnId' min='0' step='1' placeholder="Governors only allowed"/>

						<button type='submit' className="button">Submit</button>
                    </div>
                </form>

                <form onSubmit={executeHandler}>
                    <div>
                        <h3>Excecute Mint</h3>
                        <p>Enter transaction ID</p>
                        <input type='number' id='executetxn' min='0' step='1' placeholder="Governors only allowed"/>

						<button type='submit' className="button">Submit</button>
                    </div>
                </form>


				<form onSubmit={transferHandler}>
					<h3> Transfer Coins </h3>
						<p> Reciever Address </p>
						<input type='text' id='recieverAddress' className="addressInput"/>

						<p> Enter Amount </p>
						<input type='number' id='sendAmount' min='0' step='1'/>

						<button type='submit' className="button">Send</button>
						<div>
							{transferHash}
						</div>
			</form>

			{alltransactions.map((transaction, index) => {
          return (
            <div key={index} className="key">
            
            <table>
        <tr>
          <th>Address</th>
          <th>{transaction.to}</th>
        </tr>
        <tr>
          <th>Amount</th>
          <th>{transaction.amount}</th>
        </tr>
        <tr>
          <th>Data</th>
          <th>{transaction.data}</th>
        </tr>
        
        <tr>
          <th>Executed</th>
          <th>{transaction.executed}</th>
        </tr>
      </table>
            </div>
              );
          })}
			</div>
		)
	
}

export default Interactions;
